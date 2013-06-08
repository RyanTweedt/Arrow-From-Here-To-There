DrawableShapes = {

	RyanSphere = function(a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end

		local drbl = osg.ShapeDrawable(osg.Sphere(pos, a.radius or 1.0))
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end,
	Sphere = function(a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local sphere = osg.Sphere(pos, a.radius or 1.0)
		local drbl = osg.ShapeDrawable(sphere)
		local color = osg.Vec4(0,0,0,1)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end,
	Cylinder = function (a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Cylinder(pos, a.radius or 1.0, a.height or 1.0))
		local color = osg.Vec4(0,0,0,1)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end,
	CylinderFromHereToThere = function(a) 
		local midpoint = (a.here + a.there) * 0.5
		local myheight = (a.here-a.there):length()
		local xform = Transform{
			position = {midpoint:x(),midpoint:y(),midpoint:z()},
			DrawableShapes.Cylinder{height = myheight, color = a.color or {1,1,0,0}, radius = a.radius or .125},
		}
		local newVec = a.there - a.here
		local newQuat = osg.Quat()
		newQuat:makeRotate(osg.Vec3(0,0,1),osg.Vec3(newVec:x(),newVec:y(),newVec:z()))
		xform:setAttitude(newQuat)
		return xform
	end,
	Cube = function(a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Box(pos, a.width or 1.0))
		local color = osg.Vec4(0,0,0,0)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end,
	Box = function(a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Box(pos, a.width or 1.0,a.height or 1.0,a.depth or 1.0))
		local color = osg.Vec4(0,0,0,0)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end,
	Capsule = function(a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Capsule(pos, a.radius or 1.0,a.height or 1.0))
		local color = osg.Vec4(0,0,0,0)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end,
	Cone = function(a)
		local pos = osg.Vec3(0.0, 0.0, 0.0)
		if a.position then
			pos:set(unpack(a.position))
		end
		local drbl = osg.ShapeDrawable(osg.Cone(pos, a.radius or 1.0,a.height or 1.0))
		local color = osg.Vec4(0,0,0,0)
		if a.color then
			color:set(unpack(a.color))
		end
		drbl:setColor(color)
		local geode = osg.Geode()
		geode:addDrawable(drbl)
		return geode
	end,
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	ArrowFromHereToThere = function(a)
		--Default values
		local defaultColor = {1,0,0,1} --Default to red
		local defaultRadius = 0.025 --Default radius
		local coneUnpackingOffset = 0.25 --The cone unpacks about its centroid, which happens to be 1/4 from the base
		--Use for control of proportions
		local lengthProportions = 0.75 --Length proportions between cone height and cylinder length for variable cone height
		local constantLengthProportions = 6 --Height of the cone in proportion to the radius of the cylinder for constant cone height
		local radiusProportions = 2.5 --Radius proportions for the cone and the cylinder
		--Equations
		if a.variableCone then --Set this value to true for variable cone height
			coneHeight = (1 - lengthProportions)*((a.here-a.there):length()) --Set the height of the cone to the remaining distance
			cylinderEnd = lengthProportions*(a.there - a.here) + a.here --Scale down the length of the cylinder
			coneOffset = (0.5-((1 - lengthProportions)*(coneUnpackingOffset)))*((a.here-a.there):length()) --Translate the cone along the cylinder to the end
		else --Otherwise just use a constant one
			coneHeight = constantLengthProportions*(a.radius or defaultRadius) --Set the height of the cone
			cylinderEnd = (a.there - (coneHeight/((a.there - a.here):length()))*(a.there - a.here)) --Subtract the height of the cone from the length of the cylinder
			coneOffset = (0.5*((cylinderEnd - a.here):length()) + coneUnpackingOffset*coneHeight) --Translate the cone along the cylinder to the end
		end
		group = DrawableShapes.CylinderFromHereToThere{
					here = a.here, 
					there = cylinderEnd, 
					radius = a.radius or defaultRadius, 
					color = a.color or defaultColor
					}
		arrowTip = DrawableShapes.Cone{
					position = {0,0,coneOffset},
					color=a.color or defaultColor, 
					radius = radiusProportions*(a.radius or defaultRadius), 
					height=coneHeight
					}
		group:addChild(arrowTip)
		return (group)
	end,
}