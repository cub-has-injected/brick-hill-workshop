class_name BrickHillResources

const SURFACE_ICONS: = {
	"flat":preload("res://ui/icons/workshop-assets/Tiles/Flat.png"), 
	"smooth":preload("res://ui/icons/workshop-assets/Tiles/Smooth.png"), 
	"studs":preload("res://ui/icons/workshop-assets/Tiles/Studs.png"), 
	"inlets":preload("res://ui/icons/workshop-assets/Tiles/Inlets.png"), 
	"alternating":preload("res://ui/icons/workshop-assets/Tiles/Alternating.png"), 
	"alternating_flipped":preload("res://ui/icons/workshop-assets/Tiles/AlternatingFlipped.png"), 
}

const SURFACE_BITMASKS: = {
	"flat":0, 
	"smooth":8, 
	"studs":1, 
	"inlets":5, 
	"alternating":3, 
	"alternating_flipped":7, 
}

const ICONS: = {
	"tree_cube":preload("res://ui/icons/workshop-assets/Parts/Brick.png"), 
	"tree_highlight_cube":preload("res://ui/icons/workshop-assets/Parts/selectBrick.png"), 
	"tree_wedge":preload("res://ui/icons/workshop-assets/Parts/Wedge.png"), 
	"tree_highlight_wedge":preload("res://ui/icons/workshop-assets/Parts/selectWedge.png"), 
	"tree_special":preload("res://ui/icons/workshop-assets/Parts/Special.png"), 
	"tree_highlight_special":preload("res://ui/icons/workshop-assets/Parts/selectSpecial.png"), 
	"tree_round":preload("res://ui/icons/workshop-assets/Parts/Round.png"), 
	"tree_highlight_round":preload("res://ui/icons/workshop-assets/Parts/selectRound.png"), 
	"tree_glue":preload("res://ui/icons/workshop-assets/Parts/Glue.png"), 
	"tree_highlight_glue":preload("res://ui/icons/workshop-assets/Parts/selectGlue.png"), 
	"tree_group":preload("res://ui/icons/workshop-assets/Parts/Group.png"), 
	"tree_highlight_group":preload("res://ui/icons/workshop-assets/Parts/selectGroup.png"), 
	"tree_script":preload("res://ui/icons/workshop-assets/Parts/Script.png"), 
	"tree_highlight_script":preload("res://ui/icons/workshop-assets/Parts/selectScript.png"), 
	"tree_sticker":preload("res://ui/icons/workshop-assets/Parts/Sticker.png"), 
	"tree_highlight_sticker":preload("res://ui/icons/workshop-assets/Parts/selectSticker.png"), 
}

const SHADERS: = {
	"model_opaque":preload("res://resources/material/workshop/brick/model_opaque.shader"), 
	"model_transparent":preload("res://resources/material/workshop/brick/model_transparent_fake.shader")
}

const SURFACE_TEXTURES: = {
	"normal":preload("res://resources/texture/parts/surface_stud_normal.png"), 
	"depth":preload("res://resources/texture/parts/surface_stud_depth.png")
}

const MATERIAL_ALBEDO_TEXTURES: = {
	"plastic":preload("res://resources/texture/surfaces/Plastic.png"), 
	"concrete":preload("res://resources/texture/surfaces/Concrete.png"), 
	"crystal":preload("res://resources/texture/surfaces/Crystal.png"), 
	"grass":preload("res://resources/texture/surfaces/Grass.png"), 
	"ice":preload("res://resources/texture/surfaces/Ice.png"), 
	"stone":preload("res://resources/texture/surfaces/Stone.png"), 
	"wood":preload("res://resources/texture/surfaces/Wood.png"), 
	
}

const MATERIAL_NORMAL_TEXTURES: = {
	"plastic":preload("res://resources/texture/surfaces/PlasticNormal.png"), 
	"concrete":preload("res://resources/texture/surfaces/ConcreteNormal.png"), 
	"crystal":preload("res://resources/texture/surfaces/CrystalNormal.png"), 
	"grass":preload("res://resources/texture/surfaces/GrassNormal.png"), 
	"ice":preload("res://resources/texture/surfaces/IceNormal.png"), 
	"stone":preload("res://resources/texture/surfaces/StoneNormal.png"), 
	"wood":preload("res://resources/texture/surfaces/WoodNormal.png"), 
	"test":preload("res://resources/texture/surfaces/PlasticNormal.png"), 
}

const THEMES: = {
	"workshop_general_spinbox":preload("res://ui/themes/workshop_general_spinbox.tres")
}

const FONTS: = {
	"regular":preload("res://resources/dynamic_font/montserrat_regular.tres"), 
	"semibold":preload("res://resources/dynamic_font/montserrat_semibold.tres"), 
	"light":preload("res://resources/dynamic_font/montserrat_light.tres")
}
