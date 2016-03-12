#
# Table management/editing script
#
# Meant for in-game access to tables
# stored in files for use as resources
#
extends ScrollContainer

export(NodePath) var who
export(Color) var hdg_color=Color(1,.5,.75)
export(Color) var type_color=Color(.5,.75,.75)

var data
var view
var row_count
var col_count
var head
var type_labels=[]
var head_ctls=[]
var col_types=[]
var row_ctls=[]

func typestr(typeid):
	return {
		TYPE_REAL: "number",
		TYPE_STRING: "string"
	}[typeid]

func on_cell_update(what,who,row,col):
	# give a visual cue these cells have been modified
	who.set("custom_colors/font_color",Color(.75,0,0))

func clear_view():
	for lbl in type_labels:
		lbl.queue_free()
	type_labels.clear()
	for hdg in head_ctls:
		hdg.queue_free()
	head_ctls.clear()
	for cell in row_ctls:
		cell.queue_free()
	row_ctls.clear()
	col_types.clear()

func adjust_control_text(ctl,text):
	var hsize=max(100,round(1.5*get_font("").get_string_size(text).x))
	var bound=Vector2(hsize,24)
	ctl.set_custom_minimum_size(bound)
	ctl.set_text(text)
	ctl.show()

func rollback():
	populate_view()

func commit():
	print("Host before: ",data.table_data)
	data.table_data["Head"].clear()
	data.table_data["Rows"].clear()
	var sep=""
	var out="Types: "
	for type in col_types:
		out="%s%s%s" % [out,sep,typestr(type)]
		sep=", "
	print(out)
	out="Columns:"
	for hdg in head_ctls:
		data.table_data["Head"].append(hdg.get_text())
		out="%s %s" % [out,hdg.get_text()]
	print(out)
	var cell=0
	var colidx=0
	var cur_row
	for row in range(row_count):
		out="Row %s: " % (row+1)
		sep=""
		cur_row=[]
		for col in range(col_count):
			if col_types[colidx]==TYPE_REAL:
				cur_row.append(float(row_ctls[cell].get_text()))
			else:
				cur_row.append(row_ctls[cell].get_text())
			out="%s%s%s" % [out,sep,row_ctls[cell].get_text()]
			cell+=1
			sep=","
			colidx=(colidx+1) % col_count
		data.table_data["Rows"].append(cur_row)
		print(out)
	print("Host after: ",data.table_data)
	data.commit()
	populate_view()

func add_row():
	var ctl
	for i in range(col_count):
		ctl=LineEdit.new()
		ctl.set("custom_colors/font_color",Color(.75,0,0))
		view.add_child(ctl)
		row_ctls.append(ctl)
		if col_types[i]==TYPE_REAL:
			adjust_control_text(ctl,"0")
	row_count+=1

func add_col(celldef):
	view.set_columns(1+col_count)
	var tcol=Label.new()
	tcol.set("custom_colors/font_color",type_color)
	if celldef=="0":
		tcol.set_text("number")
		col_types.append(TYPE_REAL)
	else:
		tcol.set_text("string")
		col_types.append(TYPE_STRING)
	type_labels.append(tcol)
	var gridpos=col_count
	view.add_child(tcol)
	view.move_child(tcol,gridpos)
	gridpos+=(1+col_count)
	var hdcol=LineEdit.new()
	hdcol.set("custom_colors/font_color",Color(.75,0,0))
	adjust_control_text(hdcol,"column_%s" % (1+col_count))
	head_ctls.append(hdcol)
	view.add_child(hdcol)
	view.move_child(hdcol,gridpos)
	gridpos+=(1+col_count)
	var cellpos=col_count
	for i in range(row_count):
		var ctl=LineEdit.new()
		ctl.set("custom_colors/font_color",Color(.75,0,0))
		adjust_control_text(ctl,celldef)
		view.add_child(ctl)
		view.move_child(ctl,gridpos)
		gridpos+=(1+col_count)
		row_ctls.insert(cellpos,ctl)
		cellpos+=(1+col_count)
	col_count+=1

func populate_view():
	# clear current view
	clear_view()
	# determine current table spec
	row_count=data.row_count()
	head=data.get_columns()
	col_count=head.size()
	view.set_columns(col_count)
	var hdg
	var hd
	var lbl
	# placeholders for type labels
	for i in range(col_count):
		lbl=Label.new()
		view.add_child(lbl)
		lbl.set("custom_colors/font_color",type_color)
		type_labels.append(lbl)
		lbl.show()
	# populate column headings
	for i in range(col_count):
		# create heading's edit control
		hdg=LineEdit.new()
		# connected handler indicates edited content
		hdg.connect("text_changed",\
			self,"on_cell_update",[hdg,-1,i],CONNECT_PERSIST)
		hd=head[i]
		hdg.set_name("%s_%s" % [data.get_name(),hd])
		# add to the view
		view.add_child(hdg)
		head_ctls.append(hdg)
		# change color to indicate these are column headings
		hdg.set("custom_colors/font_color",hdg_color)
		# set text of control and size appropriately
		adjust_control_text(hdg,hd)
		# add placeholder for column's data type
		col_types.append(null)
	var ctl
	var cell_str
	var col_idx=0
	# populate cells from table rows
	for row in range(row_count):
		for cell in data.get_row(row):
			# populate column's type from first non-null
			# value encountered from each column
			if col_types[col_idx]==null:
				if typeof(cell)!=TYPE_NIL:
					col_types[col_idx]=typeof(cell)
					type_labels[col_idx].set_text(typestr(typeof(cell)))
			cell_str=str(cell)
			# create cell's edit control
			ctl=LineEdit.new()
			# connected handler indicates edited content
			ctl.connect("text_changed",\
				self,"on_cell_update",[ctl,row,col_idx],CONNECT_PERSIST)
			# add to the view
			view.add_child(ctl)
			row_ctls.append(ctl)
			# set text of control and size appropriately
			adjust_control_text(ctl,cell_str)
			# update column index
			col_idx=(col_idx+1) % col_count

func _ready():
	view=get_node("vertical/editor_view")
	view.show()
	if (who==null):
		print("Table editor %s has no table specified." % self.get_name())
	else:
		data=get_node(who)
		var ctl
		# sets action for rollback button
		ctl=get_node("vertical/operations/btn_rollback")
		ctl.connect("pressed",self,"rollback",[],CONNECT_PERSIST)
		# sets action for commit button
		ctl=get_node("vertical/operations/btn_commit")
		ctl.connect("pressed",self,"commit",[],CONNECT_PERSIST)
		# sets action for add row button
		ctl=get_node("vertical/operations/btn_add_row")
		ctl.connect("pressed",self,"add_row",[],CONNECT_PERSIST)
		# sets action for add string column button
		ctl=get_node("vertical/operations/btn_add_str")
		ctl.connect("pressed",self,"add_col",[""],CONNECT_PERSIST)
		# sets action for add numeric column button
		ctl=get_node("vertical/operations/btn_add_num")
		ctl.connect("pressed",self,"add_col",["0"],CONNECT_PERSIST)
		print("editor for ",data.get_name()," table ready.")
		populate_view()
