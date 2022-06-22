tool
extends Spatial

export(String, "t-pose", "teacherpointing", "standing-1", "sitting-1", "sitting-2") var pose = "t-pose" setget set_pose

func set_pose(pose_: String):
	pose = pose_
	$AnimationPlayer.play(pose)
