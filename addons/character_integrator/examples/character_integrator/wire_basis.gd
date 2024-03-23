class_name WireTransform
tool 

static func draw(geo:ImmediateGeometry, trx:Transform)->void :
	WireLine.draw(geo, trx.xform(Vector3.ZERO), trx.xform(Vector3.RIGHT), Color.red)
	WireLine.draw(geo, trx.xform(Vector3.ZERO), trx.xform(Vector3.UP), Color.green)
	WireLine.draw(geo, trx.xform(Vector3.ZERO), trx.xform(Vector3.BACK), Color.blue)
