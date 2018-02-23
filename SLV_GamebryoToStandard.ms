/*  
[INFO] 

NAME = GamebryoToStandard
VERSION = 1.0.1
AUTHOR = Vasily Lukyanenko
DEV = VISCO
HELP = 

[1.0.0]

* First release =

[1.0.1]

* Changed: Now works with MultiMaterial=
* Changed: Convert only selected objects=

[ABOUT]

Just create Standard material and  connect bump map to diffuse map from Gamebryo materials=
_=
How to use:=
@=
Run script on 3Ds Max above 2012, and press convert.=
Script just move bitmap from bump to diffuse slot.=

[TEST]

[SCRIPT]
*/	

fn getScriptInfo s releaseInfo: "" =
(		
	if(releaseInfo != "") do
	(
		r = getINISetting s releaseInfo
		return r
	)
	
	v = getINISetting s "INFO" "VERSION"
	a = getINISetting s "INFO" "AUTHOR"
	n = getINISetting s "INFO" "NAME"
	o = getINISetting s "ABOUT"
	c = getINISetting s "INFO" "DEV"
	h = getINISetting s "INFO" "HELP"
	
	r = for i in (getINISetting s) where i != "ABOUT" and i != "SCRIPT" and i != "COPY" collect i
	
	return #(n, a, v, o, r, c, h)
)

fn parseToLine m = 
(
	if(m.count == 0) do return ""
	
	l = ""				
	for i in m do 
	(	
		if(i[1] == "_") do l += "_______________________________________"
		l += i + "\n"
	)
	return l
)

fn convertGamebryoToStandard =
(
	m = #()
	
	if(selection.count == 0) do return messageBox "Please select objects!" title: "Warning!"
		
	for i in getClassInstances Standard do
	(
		if(i.shaderType != 0) do continue
		s = selection as array
		isDepend = false
		for ref in refs.dependents i where superClassOf ref == GeometryClass and findItem s ref != 0 do isDepend = true
		
		if(isDepend) do append m i
	)
		
	mats = makeUniqueArray m

	progressStart "Convert Materials..."
	escapeEnable

	disableSceneRedraw()
	
	iCnt = 0
	for i in mats do 
	(	
		iCnt += 1
		
		n = Standard()
		n.diffuseMap = i.bumpMap
		replaceInstances i  n
		
		progressUpdate (100.0 * iCnt / mats.count)
		if(getProgressCancel() == true) do exit			
	)
	
	enableSceneRedraw()
	
	progressEnd()
	
	msg = "Converted " + iCnt as string + " materials!"
	
	messageBox msg title: "Done!"
)

try(closeRolloutFloater _fGamebryoToStandard) catch()
global _fGamebryoToStandard = newRolloutFloater "GB -> Standard" 200 240

rollout _rGamebryoToStandard "GB -> Standard"
(
	button btnConvert "Convert" height: 45 width: 180
	
	on btnConvert pressed do convertGamebryoToStandard()
)

rollout _rAbout "About" 
(
	label lblName "" 
	label lblVer "" 
	
	label lblAuthor "" height: 30
	label lblCopy ""  height: 30
	
	on _rAbout open do
	(		
		i = getScriptInfo (getThisScriptFilename())
			
		lblName.caption = i[1]
		lblAuthor.caption = i[2]
		lblVer.caption = i[3]
		lblCopy.caption = i[6]
	)
)

addRollout _rGamebryoToStandard _fGamebryoToStandard rolledUp:false 
addRollout _rAbout _fGamebryoToStandard rolledUp:true 
