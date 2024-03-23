class_name MousePlaneControl
extends Node

"\nControl parameters for the MousePlane\n"

enum Mode{
	CustomBasis, 
	CameraAligned, 
	BillboardAxis
}

export (Mode) var mode: = Mode.CustomBasis
export (Basis) var custom_basis
export (Vector3) var billboard_axis
export (int, "UV,U,V") var axes: = 0
