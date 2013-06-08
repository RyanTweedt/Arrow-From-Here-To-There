require("Actions")
require("getScriptFilename")
require ("TransparentGroup")

vrjLua.appendToModelSearchPath(getScriptFilename())

dofile(vrjLua.findInModelSearchPath([[DrawableShapesMod.lua]]))
dofile(vrjLua.findInModelSearchPath([[simpleLights.lua]]))

--Print instructions
print[[Move the wand around using the control and alt buttons and moving the mouse, the arrow will track the wand. 
To place an arrow right click. Another arrow will begin where the last one left off.]]

--Initialize variables
newbeginning = osg.Vec3d(0,0,0)
oldbeginning = osg.Vec3d(0,0,0)
oldArrow = {}
num = 0

--Track cursor and draw a new arrow from either the origin or the end of the last arrow to the cursor
device = gadget.PositionInterface("VJWand")
Actions.addFrameAction(function()
	while true do
		arrow = DrawableShapes.ArrowFromHereToThere{
				here = (newBeginning or osg.Vec3d(0,0,0)),
				there = (device.position - osgnav.position),
				--radius=.005,
				variableCone = true,
				color={0,0,1,1},
				}
		RelativeTo.World:addChild(arrow)
		Actions.waitForRedraw()
		RelativeTo.World:removeChild(arrow)
	end
end)

--Make the current new arrow permanent and give it a number in the oldArrow array
Actions.addFrameAction(function()
	local newArrowBtn = gadget.DigitalInterface("VJButton2")
	while true do
		while not newArrowBtn.pressed do
			Actions.waitForRedraw()
		end

		while newArrowBtn.pressed do
			num = num + 1
			oldBeginning = (newBeginning or osg.Vec3d(0,0,0))
			newBeginning = (device.position - osgnav.position)
			while newArrowBtn.pressed do
				Actions.waitForRedraw()
			end
			oldArrow[num] = DrawableShapes.ArrowFromHereToThere{
							here = oldBeginning,
							there = newBeginning,
							radius=.025,
							--color={1,1,1,1},
							--variableCone = true,
							}
			RelativeTo.World:addChild(oldArrow[num])
			break
		end
	end

end)