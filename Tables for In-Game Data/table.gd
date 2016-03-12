#
# Table management script
#
# Meant for in-game access to tables
# stored in files for use as resources
#
extends Node

export(String, FILE, "*.json") var Table_Source

var table_data={"Head":[],"Rows":[]}

func clear():
	table_data={"Head":[],"Rows":[]}

func rollback():
	# rejects internal modified table data
	# and reverts to the table saved
	load_table()

func commit():
	# commits internal data by saving to the
	# external file stroing the table
	save_table()

func load_table():
	# load table from external file
	var data=File.new()
	if !data.file_exists(Table_Source):
		print("load_table: %s not found." % Table_Source)
		return
	data.open(Table_Source,File.READ)
	clear()
	table_data.parse_json(data.get_line())
	data.close()

func save_table():
	# save table to external file
	if Table_Source=="":
		print("save_table: not saving table because filename is unspecified")
		return
	var data=File.new()
	data.open(Table_Source,File.WRITE)
	data.store_line(table_data.to_json())
	data.close()

func row_count():
	return table_data["Rows"].size()

func get_row(idx):
	return table_data["Rows"][idx]

func get_row_dict(idx):
	var dictrow={}
	for i in range(table_data["Head"].size()):
		dictrow[table_data["Head"][i]]=table_data["Rows"][idx][i]
	return dictrow

func get_columns():
	return table_data["Head"]

func add_column(hdg):
	table_data["Head"].append(hdg)

func _ready():
	# if table source is valid automatically load
	print("Init table: %s" % Table_Source)
	load_table()

