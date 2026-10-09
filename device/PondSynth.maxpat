{
	"patcher": {
		"fileversion": 1,
		"appversion": {
			"major": 8,
			"minor": 6,
			"revision": 4,
			"architecture": "x64",
			"modernui": 1
		},
		"classnamespace": "box",
		"rect": [
			80.0,
			80.0,
			1700.0,
			900.0
		],
		"openrect": [
			0.0,
			0.0,
			710.0,
			169.0
		],
		"bglocked": 0,
		"openinpresentation": 1,
		"default_fontsize": 10.0,
		"default_fontface": 0,
		"default_fontname": "Arial Bold",
		"gridonopen": 1,
		"gridsize": [
			8.0,
			8.0
		],
		"gridsnaponopen": 1,
		"objectsnaponopen": 1,
		"statusbarvisible": 2,
		"toolbarvisible": 1,
		"boxanimatetime": 500,
		"enablehscroll": 1,
		"enablevscroll": 1,
		"devicewidth": 710.0,
		"description": "Pond synth v0.1",
		"digest": "",
		"tags": "",
		"style": "",
		"subpatcher_template": "",
		"boxes": [
			{
				"box": {
					"id": "obj-1",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 3,
					"patching_rect": [
						30,
						30,
						50,
						22
					],
					"outlettype": [
						"int",
						"int",
						"int"
					],
					"text": "notein"
				}
			},
			{
				"box": {
					"id": "obj-2",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 1,
					"patching_rect": [
						30,
						60,
						60,
						22
					],
					"outlettype": [
						""
					],
					"text": "pack 0 0"
				}
			},
			{
				"box": {
					"id": "obj-3",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						30,
						90,
						80,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend note"
				}
			},
			{
				"box": {
					"id": "obj-4",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 3,
					"patching_rect": [
						30,
						140,
						120,
						22
					],
					"outlettype": [
						"signal",
						"signal",
						""
					],
					"text": "pond~"
				}
			},
			{
				"box": {
					"id": "obj-5",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 0,
					"patching_rect": [
						30,
						190,
						60,
						22
					],
					"text": "plugout~"
				}
			},
			{
				"box": {
					"id": "obj-6",
					"maxclass": "newobj",
					"numinlets": 0,
					"numoutlets": 1,
					"patching_rect": [
						200,
						30,
						60,
						22
					],
					"outlettype": [
						""
					],
					"text": "r ---pp"
				}
			},
			{
				"box": {
					"id": "obj-7",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 3,
					"patching_rect": [
						900,
						30,
						90,
						22
					],
					"outlettype": [
						"bang",
						"int",
						"int"
					],
					"text": "live.thisdevice"
				}
			},
			{
				"box": {
					"id": "obj-8",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						900,
						60,
						30,
						22
					],
					"outlettype": [
						"bang"
					],
					"text": "t b"
				}
			},
			{
				"box": {
					"id": "obj-9",
					"maxclass": "jsui",
					"numinlets": 2,
					"numoutlets": 1,
					"patching_rect": [
						200,
						260,
						172,
						142
					],
					"outlettype": [
						""
					],
					"presentation": 1,
					"presentation_rect": [
						4,
						4,
						172,
						142
					],
					"filename": "pond.js",
					"parameter_enable": 0,
					"border": 0
				}
			},
			{
				"box": {
					"id": "obj-10",
					"maxclass": "jsui",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						400,
						260,
						226,
						161
					],
					"outlettype": [
						""
					],
					"presentation": 1,
					"presentation_rect": [
						182,
						4,
						222,
						160
					],
					"filename": "pads.js",
					"parameter_enable": 0,
					"border": 0
				}
			},
			{
				"box": {
					"id": "obj-11",
					"maxclass": "live.text",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						200,
						420,
						70,
						17
					],
					"outlettype": [
						"",
						""
					],
					"text": "Randomize",
					"presentation": 1,
					"presentation_rect": [
						4,
						149,
						82,
						16
					],
					"texton": "Randomize",
					"mode": 0,
					"varname": "Randomize",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Randomize",
							"parameter_shortname": "Randomize",
							"parameter_type": 2,
							"parameter_mmin": 0,
							"parameter_mmax": 1,
							"parameter_initial": [
								0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_enum": [
								"off",
								"on"
							]
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-12",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 2,
					"patching_rect": [
						200,
						445,
						70,
						22
					],
					"outlettype": [
						"",
						""
					],
					"text": "route bang"
				}
			},
			{
				"box": {
					"id": "obj-13",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 2,
					"patching_rect": [
						280,
						470,
						40,
						22
					],
					"outlettype": [
						"bang",
						""
					],
					"text": "sel 1"
				}
			},
			{
				"box": {
					"id": "obj-14",
					"maxclass": "message",
					"numinlets": 2,
					"numoutlets": 1,
					"patching_rect": [
						200,
						500,
						70,
						22
					],
					"outlettype": [
						""
					],
					"text": "randomize"
				}
			},
			{
				"box": {
					"id": "obj-15",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 0,
					"patching_rect": [
						700,
						700,
						60,
						22
					],
					"text": "s ---pp"
				}
			},
			{
				"box": {
					"id": "obj-16",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						700,
						80,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						412,
						18,
						44,
						48
					],
					"varname": "Start",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Start",
							"parameter_shortname": "Start",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 4.0,
							"parameter_initial": [
								0.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_units": "%.2f s"
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-17",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						700,
						135,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend start"
				}
			},
			{
				"box": {
					"id": "obj-18",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						790,
						80,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						458,
						18,
						44,
						48
					],
					"varname": "Pond Speed",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Pond Speed",
							"parameter_shortname": "Speed",
							"parameter_type": 0,
							"parameter_mmin": 0.1,
							"parameter_mmax": 4.0,
							"parameter_initial": [
								1.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_exponent": 2.0,
							"parameter_units": "%.2fx"
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-19",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						790,
						135,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend speed"
				}
			},
			{
				"box": {
					"id": "obj-20",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						880,
						80,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						512,
						6,
						44,
						48
					],
					"varname": "Wander",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Wander",
							"parameter_shortname": "Wander",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 100.0,
							"parameter_initial": [
								0.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 5
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-21",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						880,
						135,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend wander"
				}
			},
			{
				"box": {
					"id": "obj-22",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 1,
					"patching_rect": [
						880,
						113,
						50,
						22
					],
					"outlettype": [
						""
					],
					"text": "* 0.01"
				}
			},
			{
				"box": {
					"id": "obj-23",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						970,
						80,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						560,
						6,
						44,
						48
					],
					"varname": "Width",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Width",
							"parameter_shortname": "Width",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 100.0,
							"parameter_initial": [
								50.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 5
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-24",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						970,
						135,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend width"
				}
			},
			{
				"box": {
					"id": "obj-25",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 1,
					"patching_rect": [
						970,
						113,
						50,
						22
					],
					"outlettype": [
						""
					],
					"text": "* 0.01"
				}
			},
			{
				"box": {
					"id": "obj-26",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1060,
						80,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						608,
						6,
						44,
						48
					],
					"varname": "Detune",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Detune",
							"parameter_shortname": "Detune",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 30.0,
							"parameter_initial": [
								6.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_units": "%.1f ct"
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-27",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1060,
						135,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend detune"
				}
			},
			{
				"box": {
					"id": "obj-28",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						700,
						170,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						656,
						6,
						44,
						48
					],
					"varname": "Drift",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Drift",
							"parameter_shortname": "Drift",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 100.0,
							"parameter_initial": [
								20.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 5
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-29",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						700,
						225,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend drift"
				}
			},
			{
				"box": {
					"id": "obj-30",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 1,
					"patching_rect": [
						700,
						203,
						50,
						22
					],
					"outlettype": [
						""
					],
					"text": "* 0.01"
				}
			},
			{
				"box": {
					"id": "obj-31",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						790,
						170,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						512,
						86,
						44,
						48
					],
					"varname": "Attack",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Attack",
							"parameter_shortname": "Attack",
							"parameter_type": 0,
							"parameter_mmin": 1.0,
							"parameter_mmax": 2000.0,
							"parameter_initial": [
								8.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 2,
							"parameter_exponent": 3.0
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-32",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						790,
						225,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend attack"
				}
			},
			{
				"box": {
					"id": "obj-33",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						880,
						170,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						560,
						86,
						44,
						48
					],
					"varname": "Release",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Release",
							"parameter_shortname": "Release",
							"parameter_type": 0,
							"parameter_mmin": 10.0,
							"parameter_mmax": 5000.0,
							"parameter_initial": [
								400.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 2,
							"parameter_exponent": 3.0
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-34",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						880,
						225,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend release"
				}
			},
			{
				"box": {
					"id": "obj-35",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						970,
						170,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						608,
						86,
						44,
						48
					],
					"varname": "Velocity",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Velocity",
							"parameter_shortname": "Velocity",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 100.0,
							"parameter_initial": [
								70.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 5
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-36",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						970,
						225,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend velamt"
				}
			},
			{
				"box": {
					"id": "obj-37",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 1,
					"patching_rect": [
						970,
						203,
						50,
						22
					],
					"outlettype": [
						""
					],
					"text": "* 0.01"
				}
			},
			{
				"box": {
					"id": "obj-38",
					"maxclass": "live.dial",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1060,
						170,
						44,
						48
					],
					"outlettype": [
						"",
						"float"
					],
					"presentation": 1,
					"presentation_rect": [
						656,
						86,
						44,
						48
					],
					"varname": "Volume",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Volume",
							"parameter_shortname": "Volume",
							"parameter_type": 0,
							"parameter_mmin": -36.0,
							"parameter_mmax": 6.0,
							"parameter_initial": [
								-6.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 4
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-39",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1060,
						225,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend volume"
				}
			},
			{
				"box": {
					"id": "obj-40",
					"maxclass": "live.text",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						700,
						300,
						44,
						17
					],
					"outlettype": [
						"",
						""
					],
					"text": "Key",
					"presentation": 1,
					"presentation_rect": [
						412,
						92,
						44,
						17
					],
					"texton": "Key",
					"mode": 1,
					"varname": "Key Tracking",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Key Tracking",
							"parameter_shortname": "Key",
							"parameter_type": 2,
							"parameter_mmin": 0,
							"parameter_mmax": 1,
							"parameter_initial": [
								1
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_enum": [
								"off",
								"on"
							]
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-41",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						700,
						325,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend keytrack"
				}
			},
			{
				"box": {
					"id": "obj-42",
					"maxclass": "live.text",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						790,
						300,
						44,
						17
					],
					"outlettype": [
						"",
						""
					],
					"text": "Freeze",
					"presentation": 1,
					"presentation_rect": [
						458,
						92,
						44,
						17
					],
					"texton": "Freeze",
					"mode": 1,
					"varname": "Freeze",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Freeze",
							"parameter_shortname": "Freeze",
							"parameter_type": 2,
							"parameter_mmin": 0,
							"parameter_mmax": 1,
							"parameter_initial": [
								0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_enum": [
								"off",
								"on"
							]
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-43",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						790,
						325,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend freeze"
				}
			},
			{
				"box": {
					"id": "obj-44",
					"maxclass": "live.text",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						880,
						300,
						44,
						17
					],
					"outlettype": [
						"",
						""
					],
					"text": "View",
					"presentation": 1,
					"presentation_rect": [
						90,
						149,
						40,
						16
					],
					"texton": "View",
					"mode": 1,
					"varname": "Pond View",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Pond View",
							"parameter_shortname": "View",
							"parameter_type": 2,
							"parameter_mmin": 0,
							"parameter_mmax": 1,
							"parameter_initial": [
								1
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_enum": [
								"off",
								"on"
							]
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-45",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						880,
						325,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend display"
				}
			},
			{
				"box": {
					"id": "obj-46",
					"maxclass": "live.text",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						970,
						300,
						44,
						17
					],
					"outlettype": [
						"",
						""
					],
					"text": "Swirl",
					"presentation": 1,
					"presentation_rect": [
						134,
						149,
						42,
						16
					],
					"texton": "Flow",
					"mode": 1,
					"varname": "Current Mode",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Current Mode",
							"parameter_shortname": "Current",
							"parameter_type": 2,
							"parameter_mmin": 0,
							"parameter_mmax": 1,
							"parameter_initial": [
								0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 9,
							"parameter_enum": [
								"off",
								"on"
							]
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-47",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						970,
						325,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend cmode"
				}
			},
			{
				"box": {
					"id": "obj-48",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						700,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Corners",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Corners",
							"parameter_shortname": "Corners",
							"parameter_type": 0,
							"parameter_mmin": 3.0,
							"parameter_mmax": 12.0,
							"parameter_initial": [
								5.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-49",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						700,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend corners"
				}
			},
			{
				"box": {
					"id": "obj-50",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						810,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Walls",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Walls",
							"parameter_shortname": "Walls",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.2
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-51",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						810,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend walls"
				}
			},
			{
				"box": {
					"id": "obj-52",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						920,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Viscosity",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Viscosity",
							"parameter_shortname": "Visc",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.25
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-53",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						920,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend visc"
				}
			},
			{
				"box": {
					"id": "obj-54",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1030,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Reflect",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Reflect",
							"parameter_shortname": "Reflect",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.8
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-55",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1030,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend refl"
				}
			},
			{
				"box": {
					"id": "obj-56",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1140,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Current",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Current",
							"parameter_shortname": "Current",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.25
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-57",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1140,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend current"
				}
			},
			{
				"box": {
					"id": "obj-58",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1250,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Flow Direction",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Flow Direction",
							"parameter_shortname": "Flow Dir",
							"parameter_type": 0,
							"parameter_mmin": -3.1416,
							"parameter_mmax": 3.1416,
							"parameter_initial": [
								0.0
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-59",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1250,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend cdir"
				}
			},
			{
				"box": {
					"id": "obj-60",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1360,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Orbit X",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Orbit X",
							"parameter_shortname": "Orbit X",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.12
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-61",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1360,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend ox"
				}
			},
			{
				"box": {
					"id": "obj-62",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1470,
						400,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Orbit Y",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Orbit Y",
							"parameter_shortname": "Orbit Y",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								-0.1
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-63",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1470,
						425,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend oy"
				}
			},
			{
				"box": {
					"id": "obj-64",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						700,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Orbit Size",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Orbit Size",
							"parameter_shortname": "Orbit Sz",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.4
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-65",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						700,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend osize"
				}
			},
			{
				"box": {
					"id": "obj-66",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						810,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stones",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stones",
							"parameter_shortname": "Stones",
							"parameter_type": 1,
							"parameter_mmin": 1,
							"parameter_mmax": 4,
							"parameter_initial": [
								3
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 0
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-67",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						810,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend nstones"
				}
			},
			{
				"box": {
					"id": "obj-68",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						920,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 1 X",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 1 X",
							"parameter_shortname": "S1 X",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.5
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-69",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						920,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s1x"
				}
			},
			{
				"box": {
					"id": "obj-70",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1030,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 1 Y",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 1 Y",
							"parameter_shortname": "S1 Y",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								-0.22
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-71",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1030,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s1y"
				}
			},
			{
				"box": {
					"id": "obj-72",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1140,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 1 Height",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 1 Height",
							"parameter_shortname": "S1 Height",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.55
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-73",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1140,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s1h"
				}
			},
			{
				"box": {
					"id": "obj-74",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1250,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 1 Size",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 1 Size",
							"parameter_shortname": "S1 Size",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.35
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-75",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1250,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s1s"
				}
			},
			{
				"box": {
					"id": "obj-76",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1360,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 1 Mass",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 1 Mass",
							"parameter_shortname": "S1 Mass",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.5
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-77",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1360,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s1m"
				}
			},
			{
				"box": {
					"id": "obj-78",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1470,
						470,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 2 X",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 2 X",
							"parameter_shortname": "S2 X",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								-0.45
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-79",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1470,
						495,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s2x"
				}
			},
			{
				"box": {
					"id": "obj-80",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						700,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 2 Y",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 2 Y",
							"parameter_shortname": "S2 Y",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.3
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-81",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						700,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s2y"
				}
			},
			{
				"box": {
					"id": "obj-82",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						810,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 2 Height",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 2 Height",
							"parameter_shortname": "S2 Height",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.25
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-83",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						810,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s2h"
				}
			},
			{
				"box": {
					"id": "obj-84",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						920,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 2 Size",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 2 Size",
							"parameter_shortname": "S2 Size",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.2
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-85",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						920,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s2s"
				}
			},
			{
				"box": {
					"id": "obj-86",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1030,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 2 Mass",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 2 Mass",
							"parameter_shortname": "S2 Mass",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.85
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-87",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1030,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s2m"
				}
			},
			{
				"box": {
					"id": "obj-88",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1140,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 3 X",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 3 X",
							"parameter_shortname": "S3 X",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.12
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-89",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1140,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s3x"
				}
			},
			{
				"box": {
					"id": "obj-90",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1250,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 3 Y",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 3 Y",
							"parameter_shortname": "S3 Y",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.55
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-91",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1250,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s3y"
				}
			},
			{
				"box": {
					"id": "obj-92",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1360,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 3 Height",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 3 Height",
							"parameter_shortname": "S3 Height",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.8
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-93",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1360,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s3h"
				}
			},
			{
				"box": {
					"id": "obj-94",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1470,
						540,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 3 Size",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 3 Size",
							"parameter_shortname": "S3 Size",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.55
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-95",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1470,
						565,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s3s"
				}
			},
			{
				"box": {
					"id": "obj-96",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						700,
						610,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 3 Mass",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 3 Mass",
							"parameter_shortname": "S3 Mass",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.3
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-97",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						700,
						635,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s3m"
				}
			},
			{
				"box": {
					"id": "obj-98",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						810,
						610,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 4 X",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 4 X",
							"parameter_shortname": "S4 X",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								-0.3
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-99",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						810,
						635,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s4x"
				}
			},
			{
				"box": {
					"id": "obj-100",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						920,
						610,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 4 Y",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 4 Y",
							"parameter_shortname": "S4 Y",
							"parameter_type": 0,
							"parameter_mmin": -1.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								-0.4
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-101",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						920,
						635,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s4y"
				}
			},
			{
				"box": {
					"id": "obj-102",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1030,
						610,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 4 Height",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 4 Height",
							"parameter_shortname": "S4 Height",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.4
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-103",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1030,
						635,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s4h"
				}
			},
			{
				"box": {
					"id": "obj-104",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1140,
						610,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 4 Size",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 4 Size",
							"parameter_shortname": "S4 Size",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.3
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-105",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1140,
						635,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s4s"
				}
			},
			{
				"box": {
					"id": "obj-106",
					"maxclass": "live.numbox",
					"numinlets": 1,
					"numoutlets": 2,
					"patching_rect": [
						1250,
						610,
						50,
						15
					],
					"outlettype": [
						"",
						"float"
					],
					"varname": "Stone 4 Mass",
					"parameter_enable": 1,
					"saved_attribute_attributes": {
						"valueof": {
							"parameter_longname": "Stone 4 Mass",
							"parameter_shortname": "S4 Mass",
							"parameter_type": 0,
							"parameter_mmin": 0.0,
							"parameter_mmax": 1.0,
							"parameter_initial": [
								0.5
							],
							"parameter_initial_enable": 1,
							"parameter_unitstyle": 1
						}
					}
				}
			},
			{
				"box": {
					"id": "obj-107",
					"maxclass": "newobj",
					"numinlets": 1,
					"numoutlets": 1,
					"patching_rect": [
						1250,
						635,
						100,
						22
					],
					"outlettype": [
						""
					],
					"text": "prepend s4m"
				}
			},
			{
				"box": {
					"id": "obj-108",
					"maxclass": "newobj",
					"numinlets": 2,
					"numoutlets": 31,
					"patching_rect": [
						200,
						560,
						400,
						22
					],
					"outlettype": [
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						"",
						""
					],
					"text": "route corners walls visc refl current cdir ox oy osize nstones s1x s1y s1h s1s s1m s2x s2y s2h s2s s2m s3x s3y s3h s3s s3m s4x s4y s4h s4s s4m"
				}
			}
		],
		"lines": [
			{
				"patchline": {
					"source": [
						"obj-1",
						0
					],
					"destination": [
						"obj-2",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-1",
						1
					],
					"destination": [
						"obj-2",
						1
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-2",
						0
					],
					"destination": [
						"obj-3",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-3",
						0
					],
					"destination": [
						"obj-4",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-4",
						0
					],
					"destination": [
						"obj-5",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-4",
						1
					],
					"destination": [
						"obj-5",
						1
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-6",
						0
					],
					"destination": [
						"obj-4",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-7",
						0
					],
					"destination": [
						"obj-8",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-6",
						0
					],
					"destination": [
						"obj-9",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-6",
						0
					],
					"destination": [
						"obj-10",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-4",
						2
					],
					"destination": [
						"obj-9",
						1
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-9",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-10",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-11",
						0
					],
					"destination": [
						"obj-12",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-12",
						0
					],
					"destination": [
						"obj-14",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-12",
						1
					],
					"destination": [
						"obj-13",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-13",
						0
					],
					"destination": [
						"obj-14",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-14",
						0
					],
					"destination": [
						"obj-4",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-16",
						0
					],
					"destination": [
						"obj-17",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-17",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-16",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-18",
						0
					],
					"destination": [
						"obj-19",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-19",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-18",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-20",
						0
					],
					"destination": [
						"obj-22",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-22",
						0
					],
					"destination": [
						"obj-21",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-21",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-20",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-23",
						0
					],
					"destination": [
						"obj-25",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-25",
						0
					],
					"destination": [
						"obj-24",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-24",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-23",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-26",
						0
					],
					"destination": [
						"obj-27",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-27",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-26",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-28",
						0
					],
					"destination": [
						"obj-30",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-30",
						0
					],
					"destination": [
						"obj-29",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-29",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-28",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-31",
						0
					],
					"destination": [
						"obj-32",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-32",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-31",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-33",
						0
					],
					"destination": [
						"obj-34",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-34",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-33",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-35",
						0
					],
					"destination": [
						"obj-37",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-37",
						0
					],
					"destination": [
						"obj-36",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-36",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-35",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-38",
						0
					],
					"destination": [
						"obj-39",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-39",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-38",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-40",
						0
					],
					"destination": [
						"obj-41",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-41",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-42",
						0
					],
					"destination": [
						"obj-43",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-43",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-44",
						0
					],
					"destination": [
						"obj-45",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-45",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-46",
						0
					],
					"destination": [
						"obj-47",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-47",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-48",
						0
					],
					"destination": [
						"obj-49",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-49",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-48",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-50",
						0
					],
					"destination": [
						"obj-51",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-51",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-50",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-52",
						0
					],
					"destination": [
						"obj-53",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-53",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-52",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-54",
						0
					],
					"destination": [
						"obj-55",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-55",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-54",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-56",
						0
					],
					"destination": [
						"obj-57",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-57",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-56",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-58",
						0
					],
					"destination": [
						"obj-59",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-59",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-58",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-60",
						0
					],
					"destination": [
						"obj-61",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-61",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-60",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-62",
						0
					],
					"destination": [
						"obj-63",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-63",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-62",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-64",
						0
					],
					"destination": [
						"obj-65",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-65",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-64",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-66",
						0
					],
					"destination": [
						"obj-67",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-67",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-66",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-68",
						0
					],
					"destination": [
						"obj-69",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-69",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-68",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-70",
						0
					],
					"destination": [
						"obj-71",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-71",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-70",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-72",
						0
					],
					"destination": [
						"obj-73",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-73",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-72",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-74",
						0
					],
					"destination": [
						"obj-75",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-75",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-74",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-76",
						0
					],
					"destination": [
						"obj-77",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-77",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-76",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-78",
						0
					],
					"destination": [
						"obj-79",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-79",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-78",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-80",
						0
					],
					"destination": [
						"obj-81",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-81",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-80",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-82",
						0
					],
					"destination": [
						"obj-83",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-83",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-82",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-84",
						0
					],
					"destination": [
						"obj-85",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-85",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-84",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-86",
						0
					],
					"destination": [
						"obj-87",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-87",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-86",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-88",
						0
					],
					"destination": [
						"obj-89",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-89",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-88",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-90",
						0
					],
					"destination": [
						"obj-91",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-91",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-90",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-92",
						0
					],
					"destination": [
						"obj-93",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-93",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-92",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-94",
						0
					],
					"destination": [
						"obj-95",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-95",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-94",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-96",
						0
					],
					"destination": [
						"obj-97",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-97",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-96",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-98",
						0
					],
					"destination": [
						"obj-99",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-99",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-98",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-100",
						0
					],
					"destination": [
						"obj-101",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-101",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-100",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-102",
						0
					],
					"destination": [
						"obj-103",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-103",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-102",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-104",
						0
					],
					"destination": [
						"obj-105",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-105",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-104",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-106",
						0
					],
					"destination": [
						"obj-107",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-107",
						0
					],
					"destination": [
						"obj-15",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-8",
						0
					],
					"destination": [
						"obj-106",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-9",
						0
					],
					"destination": [
						"obj-108",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-10",
						0
					],
					"destination": [
						"obj-108",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						0
					],
					"destination": [
						"obj-48",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						1
					],
					"destination": [
						"obj-50",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						2
					],
					"destination": [
						"obj-52",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						3
					],
					"destination": [
						"obj-54",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						4
					],
					"destination": [
						"obj-56",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						5
					],
					"destination": [
						"obj-58",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						6
					],
					"destination": [
						"obj-60",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						7
					],
					"destination": [
						"obj-62",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						8
					],
					"destination": [
						"obj-64",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						9
					],
					"destination": [
						"obj-66",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						10
					],
					"destination": [
						"obj-68",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						11
					],
					"destination": [
						"obj-70",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						12
					],
					"destination": [
						"obj-72",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						13
					],
					"destination": [
						"obj-74",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						14
					],
					"destination": [
						"obj-76",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						15
					],
					"destination": [
						"obj-78",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						16
					],
					"destination": [
						"obj-80",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						17
					],
					"destination": [
						"obj-82",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						18
					],
					"destination": [
						"obj-84",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						19
					],
					"destination": [
						"obj-86",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						20
					],
					"destination": [
						"obj-88",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						21
					],
					"destination": [
						"obj-90",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						22
					],
					"destination": [
						"obj-92",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						23
					],
					"destination": [
						"obj-94",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						24
					],
					"destination": [
						"obj-96",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						25
					],
					"destination": [
						"obj-98",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						26
					],
					"destination": [
						"obj-100",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						27
					],
					"destination": [
						"obj-102",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						28
					],
					"destination": [
						"obj-104",
						0
					]
				}
			},
			{
				"patchline": {
					"source": [
						"obj-108",
						29
					],
					"destination": [
						"obj-106",
						0
					]
				}
			}
		],
		"dependency_cache": [
			{
				"name": "pond.js",
				"bootpath": ".",
				"patcherrelativepath": ".",
				"type": "TEXT",
				"implicit": 1
			},
			{
				"name": "pads.js",
				"bootpath": ".",
				"patcherrelativepath": ".",
				"type": "TEXT",
				"implicit": 1
			},
			{
				"name": "pond~.mxo",
				"type": "iLaX"
			}
		],
		"latency": 0,
		"is_mpe": 0,
		"minimum_live_version": "",
		"minimum_max_version": "",
		"platform_compatibility": 0,
		"project": {
			"version": 1,
			"creationdate": 3590052493,
			"modificationdate": 3590052493,
			"viewrect": [
				0.0,
				0.0,
				300.0,
				500.0
			],
			"autoorganize": 1,
			"hideprojectwindow": 1,
			"showdependencies": 1,
			"autolocalize": 0,
			"contents": {
				"patchers": {}
			},
			"layout": {},
			"searchpath": {},
			"detailsvisible": 0,
			"amxdtype": 1768515945,
			"readonly": 0,
			"devpathtype": 0,
			"devpath": ".",
			"sortmode": 0,
			"viewmode": 0,
			"includepackages": 0
		},
		"autosave": 0
	}
}