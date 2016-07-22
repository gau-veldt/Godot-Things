extends Node

#
# Network stream management
#
# Allows asynchronous network access with signals to indicate
# completion of accesses.
#
# The process loop will consume network data as it is received
# and place it into a recieving FIFO.  Data bound for the network
# (the send_xxx methods) will placed into a sending FIFO.  Bytes
# will come off the send FIFO as the underlying OS FIFO takes
# it up (put_data_partial).
#
# An additional signal is present and will fire if the connection
# is dropped.
#

var connect_timeout=10

signal Connected(host)
signal ConnectTimeout()
signal Disconnected(host)
signal NetworkError(host)
signal GotData(host,data)
signal SendingFinished(host)

var host=null
var signalConnect=false
var wasConnected=false
var connect_thread=null
var connect_attempt_elapsed
var _thd_done

var recvFIFO=RawArray()
var sendFIFO=RawArray()

func left_delete(raw,amt):
	# deletes amt bytes from beginning of rawarray
	if amt>=raw.size():
		raw.resize(0)
		return raw
	if amt<=0:
		# nothing to do
		return raw
	#
	# *** THIS IS A HACK ***
	# We need a subarray (slice) operation to do this properly
	# This hack will copy the entire data three times!!! O(N)
	# as RawArray's copy when modified.
	# Alas this hack is still faster than scriptlooping to
	# left-delete using .remove() and having the data copied on
	# each pass through the loop! O(N^2+N) (for a mere 10 KB
	# of data scriptlooping results in 50 MB!!! of wasted copying,
	# whereas this hack only copies 30K)
	#
	raw.invert()
	raw.resize(raw.size()-amt)
	raw.invert()
	return raw

func connect_worker(args):
	var addr=args[0]
	var port=args[1]
	var host=StreamPeerTCP.new()
	var err=host.connect(addr,port)
	while host.get_status()==1:
		pass
	_thd_done=true
	return [err,host]

func connectToPeer(addr,port):
	connect_attempt_elapsed=0.0
	connect_thread=Thread.new()
	_thd_done=false
	connect_thread.start(self,"connect_worker",[addr,port])

var _st
var pair
var partial
var avl
func _process(delta):

	if connect_thread!=null:
		connect_attempt_elapsed+=delta
		if _thd_done:
			# this means the thread connected
			var rc=connect_thread.wait_to_finish()
			connect_thread=null
			attach(rc[1])
			signalConnect=true
		else:
			if connect_attempt_elapsed>=connect_timeout:
				# API gives no way to kill a thread???
				# best we cand do then is force its refcount to 0
				connect_thread=null
				# indicate the timeout downstream
				emit_signal("ConnectTimeout")

	if host!=null:
		_st=host.get_status()
		if _st==2:
			wasConnected=true
			if signalConnect:
				signalConnect=false
				emit_signal("Connected",host)
		if (_st==0 or !host.is_connected()) and wasConnected:
			emit_signal("Disconnected",host)
			detach()
			return
		if _st==3:
			emit_signal("NetworkError",host)
			detach()
			return

		if sendFIFO.size()>0:
			pair=host.put_partial_data(sendFIFO)
			partial=pair[1]
			sendFIFO=left_delete(sendFIFO,partial)
			if sendFIFO.size()==0:
				emit_signal("SendingFinished",host)

		avl=host.get_available_bytes()
		if avl>0:
			recvFIFO.append_array(host.get_data(avl)[1])
			emit_signal("GotData",host,recvFIFO)
			recvFIFO.resize(0)

func write(what):
	sendFIFO.append_array(what)

func writestr(what):
	sendFIFO.append_array(what.to_utf8())

func disconnect():
	if host!=null:
		host.disconnect()

func attach(stream):
	var st=stream.get_status()
	if st==1 or st==2:
		host=stream
		wasConnected=true
		if st==1:
			signalConnect=true
		return true
	return false

func detach():
	host=null
	recvFIFO.resize(0)
	sendFIFO.resize(0)

func _ready():
	set_process(true)
