Pox_ParseChecklist(File)
	{
	GLOBAL
	RunesToSac := ""
	RunesToSacText := ""
	FileRead ,Checklist,%File%
	StringReplace, Checklist, Checklist,\u0027,', All 
	ChecklistLength := StrLen(Checklist)


	
	;find boundaries for rune type sections
	ChampionsPos := RegExMatch(Checklist,"""champions""") ;14
	SpellsPos := RegExMatch(Checklist,"],""spells""") ;162431
	RelicsPos := RegExMatch(Checklist,"],""relics""") ;206267
	EquipmentPos := RegExMatch(Checklist,"],""equipment""") ;223210
	FactionsPos := RegExMatch(Checklist,"],""factions""")
	ReleasesPos := RegExMatch(Checklist,"],""releases""")
	RaritiesPos := RegExMatch(Checklist,"],""rarities""")
	RacesPos := RegExMatch(Checklist,"],""races""",n,RaritiesPos) ;starting pos is set to rarities beginning pos so that it doesnt find "races" in runes section
	ClassesPos := RegExMatch(Checklist,"],""classes""",n,RacesPos) ;same as above

	;divide checklist into blocks by rune type
	ChampionsBlock := SubStr(Checklist,ChampionsPos,(SpellsPos-ChampionsPos))
	SpellsBlock := SubStr(Checklist,SpellsPos,(RelicsPos-SpellsPos))
	RelicsBlock := SubStr(Checklist,RelicsPos,(EquipmentPos-RelicsPos))
	EquipmentBlock := SubStr(Checklist,EquipmentPos,(FactionsPos-EquipmentPos))
	FactionsBlock := SubStr(Checklist,FactionsPos,(ReleasesPos-FactionsPos))
	ReleasesBlock := SubStr(Checklist,ReleasesPos,(RaritiesPos-ReleasesPos))
	RaritiesBlock := SubStr(Checklist,RaritiesPos,(RacesPos-RaritiesPos))
	RacesBlock := SubStr(Checklist,RacesPos,(ClassesPos-RacesPos))
	ClassesBlock := SubStr(Checklist,ClassesPos,(ChecklistLength-ClassesPos))

	;init arrays
	AllRunes := Object()
	ChampionsRunes := Object()
	SpellsRunes := Object()
	RelicsRunes := Object()
	EquipmentRunes := Object()

	RefType1 := "factions"
	RefType2 := "releases"
	RefType3 := "rarities"
	RefType4 := "races"
	RefType5 := "classes"

	Loop 5 ;build id ref tables
		{
		CurrentType := RefType%a_index%
		%CurrentType%Array := Object() ;initialize ref array
		Loop,Parse,%CurrentType%Block,{
			{
			RegExMatch(A_LoopField,"""id"":(\d*)",id)
			RegExMatch(A_LoopField,"""value"":""([^""]*)""",value)
			%CurrentType%Array[id1] := value1
			;msgbox % "id= " . id1 . "`n" . %CurrentType%Array[id1]
			}
		}
	
	RuneType1 := "champions"
	RuneType2 := "spells"
	RuneType3 := "relics"
	RuneType4 := "equipment"
		
	Loop 4 ;once for each rune type and instantiate runes.
		{
		CurrentType := RuneType%a_index%
		Loop,Parse,%CurrentType%Block,{
			{
			RegExMatch(A_LoopField,"""clazzes"":\[([\d,]*)],",Class)
			RegExMatch(A_LoopField,"""races"":\[([\d,]*)],",Race)
			RegExMatch(A_LoopField,"""id"":(-?\d*),",id)
			RegExMatch(A_LoopField,"""baseId"":(\d*),",baseid)
			RegExMatch(A_LoopField,"""name"":""([^""]*)"",",name)
			RegExMatch(A_LoopField,"""count"":(\d*),",count)
			RegExMatch(A_LoopField,"""rarity"":(\d*),",rarity)
			RegExMatch(A_LoopField,"""release"":(\d*),",release)
			RegExMatch(A_LoopField,"""factions"":\[(\d*,?\d*)]}",factions)
			;msgbox %factions1%
			new Rune(CurrentType,class1,race1,id1,baseid1,name1,count1,rarity1,release1,factions1) 
			}
		}
		
	Gui, Checklist: Add, ListView, x25 y180 w550 h300 +AltSubmit Checked -readonly grid hwndHLV vLV, Custom Sac Qty|Name|Count|RuneType|Rarity|Faction|Reference id|Release
	Gui, checklist: Add, Text, x25 y500 cBlue gLink1 vURL_Link1, http://www.poxbrothers.info/
	Gui, checklist: Add, Radio, vMassSac x58 y10 w390 checked gMassEnable, Sacrifice all runes in excess of this amount according to options below`n(select the runes you don't want to be sacrificed).
	Gui, checklist: Add, Radio, vManualSac x25 y48 gManualEnable, Select runes to sacrifice (select the rune and press F2 to edit the # of runes that should be sacrificed).
	Gui, checklist: Add, Checkbox, vSaccommon x270 y100 cFFC400, Sacrifice Commons
	Gui, checklist: Add, Checkbox, vSacUncommon x135 y100 cRed, Sacrifice Uncommons
	Gui, checklist: Add, Checkbox, vSacRare x25 y100 cBlue, Sacrifice Rares	
	Gui, checklist: Add, Checkbox, vSkipLeveled x25 y75 checked, Skip leveled runes (runes with 200 CP)
	Gui, checklist: Add, Checkbox, vSacChampions x25 y125 Checked, Sac Champs
	Gui, checklist: Add, Checkbox, vSacSpells x110 y125 Checked, Sac Spells
	Gui, checklist: Add, Checkbox, vSacEquipment x185 y125 Checked, Sac Equipment
	Gui, checklist: Add, Checkbox, vSacRelics x280 y125 Checked, Sac Relics
	Gui, checklist: Add, text, x25 y153, Sacrifice only runes from this faction:
	Gui, checklist: Add, DropdownList, vRuneFactionFilter x200 y150 w120, All Factions||Forglar Swamp|Forsaken Wastes|Ironfist Stronghold|K'thir Forest|Savage Tundra|Shattered Peaks|Sundered Lands|Underdepths

	;Gui, checklist: Add, Text, x255 y77, Current Release Set (Will be skipped):
	MaxIndex := ReleasesArray.MaxIndex()
	CurrentReleaseSet := ReleasesArray[MaxIndex]
	;for key,value in ReleasesArray
		;ReleaseList .= value . "|"
	;ReleaseList .= "|" ;adds double pipe to final set to pre-select
	;Gui, checklist: Add, DropDownList, vCurrentReleaseSet x450 y73, %ReleaseList%
	Gui, checklist: Add, edit, vMassSacAmount number x25 y10 w30 , 4
	Gui, checklist: Add, button, x450 y75 h30 w115 gSacrificeButton, SACRIFICE
	Gui, checklist: Add, edit, x450 y115 w115 gSearchField vsearchfield, Search
	Gui, Checklist:  +Resize +hwndChecklistWindowHandle
	Gui, Checklist:  Show, h525 w600, %username%'s Rune Checklist - Poxbros Mass Shard
	Gui, Checklist:Default
	for key,value in AllRunes
		{
		FactionsValue := ""
		ToParse := ""
		ToParse := value.faction
		if (ToParse != "")
			{
			Loop, Parse, ToParse, `,,
				{
				FactionsValue .= FactionsArray[A_LoopField] . ", "
				}
			}
		StringTrimRight, FactionsValue,FactionsValue,2 ;trim trailing delimiter
		LV_Add("",0,value.name,value.count,value.runetype , RaritiesArray[value.rarity],FactionsValue,value.UniqueKey,ReleasesArray[value.release])
		}
	LV_ModifyCol() ;resize to fit contents
	LV_ModifyCol(1,"AutoHdr") ;Resize columns to fit Headers
	LV_ModifyCol(2,"AutoHdr") ;Resize columns to fit Headers
	LV_ModifyCol(3,"AutoHdr") ;Resize columns to fit Headers
	LV_ModifyCol(4,"AutoHdr") ;Resize columns to fit Headers
	LV_ModifyCol(3,"AutoHdr Integer SortDesc") ;Resize columns to fit Headers, sort by count
	LV_ModifyCol(5,"AutoHdr") ;Resize columns to fit Headers
	return
	
	ManualEnable:
	GuiControl, checklist: -ReadOnly,LV
	GuiControl, checklist: disable,Saccommon
	GuiControl, checklist: disable,Sacuncommon
	GuiControl, checklist: disable,Sacrare
	GuiControl, checklist: disable,MassSacAmount
	GuiControl, checklist: disable,RuneFactionFilter
	GuiControl, checklist: disable,SacChampions
	GuiControl, checklist: disable,SacSpells
	GuiControl, checklist: disable,Sacrelics
	GuiControl, checklist: disable,Sacequipment
	return
	
	MassEnable:
	GuiControl, checklist: +ReadOnly,LV
	GuiControl, checklist: enable,Saccommon
	GuiControl, checklist: enable,Sacuncommon
	GuiControl, checklist: enable,Sacrare
	GuiControl, checklist: enable,MassSacAmount
	GuiControl, checklist: enable,RuneFactionFilter
	GuiControl, checklist: enable,SacChampions
	GuiControl, checklist: enable,SacSpells
	GuiControl, checklist: enable,Sacrelics
	GuiControl, checklist: enable,Sacequipment	
	return	
	
	ChecklistGuiClose:
	ExitApp
	
	SearchField:
	Gui, Checklist: submit, nohide
	if !searchfield
		return
	Loop % LV_GetCount()
		{
		LV_GetText(name, a_index,2)
		;msgbox comparing %name% and %searchfield%
		if !(RegExMatch(name,"i)^" . searchfield))
			{
			;msgbox no match
			continue
			}
		else
			{
			;msgbox match
			LV_Modify(a_index, "select focus vis")
			return
			}
		}
	return
	
	SacrificeButton:
	Gui, Checklist: submit, nohide
	if (MassSac and SacCommon = 0 and SacUncommon = 0 and SacRare = 0)
		{
		msgbox,4144,,You must check one of the three rarity checkboxes first.
		return 0
		}
	if (MassSac and SacChampions = 0 and SacSpells = 0 and SacRelics = 0 and SacEquipment = 0)
		{
		msgbox,4144,,You must check one of the four rune type checkboxes first.
		return 0
		}
	RowNumber = 0  ; This causes the first loop iteration to start the search at the top of the list.
	Loop ;get custom checked runes and add to list
		{
		RowNumber := LV_GetNext(RowNumber,"Checked")  ; Resume the search at the row after that found by the previous iteration.
		if not RowNumber  ; The above returned zero, so there are no more selected rows.
			break
		LV_GetText(count, RowNumber,3)
		LV_GetText(uniqueKey, RowNumber,7)
		LV_GetText(name, RowNumber,2)
		LV_GetText(sacCount, RowNumber,1)
		LV_GetText(RuneType, RowNumber,4)
		LV_GetText(Faction, RowNumber,6)
		if (SacCount = "")
			{
			msgbox,4144,,Rune %name% was checked, but no sacrifice quantity specified. It will not be sacrificed. Press F2 to edit the quantity for a rune while it is selected next time.
			continue
			}		
		sacAmount := count-SacCount
		if (sacAmount < 0) ;not enough runes, skip it
			{
			msgbox,4144,,Rune %name% was checked, and set for %SacCount% to be sacrificed, but you only have %count%. It will not be sacrificed.
			continue
			}		
		LV_GetText(release, RowNumber,8)
		if (release = CurrentReleaseSet) ;current release set
			{
			msgbox,4144,,Rune %name% is from the %release% release set, which is the current release set and cannot yet be sacrificed. It will be skipped.
			continue
			}
		if (SacCount = 0 or MassSac)
			{
			RunesToSkip .= "$" . uniqueKey
			continue
			}		
		RunesToSac .= "$" . uniqueKey . "|" . sacCount
		RunesToSacText .= "`n" . name . "-----------------" . sacCount . "-----------------" . count
		}
	if MassSac
		{
		if (MassSacAmount = "")
			{
			msgbox,4144,,When using Mass Sacrifice you must specify a threshold value.
			return 0
			}
		Loop % LV_GetCount()
			{
			LV_GetText(count, a_index,3)
			sacCount := count-MassSacAmount
			LV_GetText(Faction, a_index,6)
			if (RuneFactionFilter != "All Factions")
				if !(InStr(Faction, RuneFactionFilter))
				continue
			LV_GetText(RuneType, a_index,4)
			if !(Sac%RuneType%) ;not saccing that runetype
				continue
			if (sacCount < 1) ;not enough runes, skip it
				continue
			LV_GetText(rarity, a_index,5)
			if (Sac%rarity% != 1) ;not saccing that rarity
				continue
			LV_GetText(release, a_index,8)
			if (release = CurrentReleaseSet) ;current release set
				continue
			LV_GetText(uniqueKey, a_index,7)
			if (instr(RunesToSkip,uniqueKey)) ;if checked, skip it
				continue				
			LV_GetText(name, a_index,2)
			RunesToSac .= "$" . uniqueKey . "|" . sacCount
			RunesToSacText .= "`n" . name . "-----------------" . sacCount . "-----------------" . count
			}
		}
	if !RunesToSac
		{
		msgbox,4144,,Either you did not select any runes to sacrifice, you did not check the "Sacrifice runes in excess..." checkbox and enter a value, or the runes you did check were all skipped.`n`nPlease check your settings and try again.
		return 0
		}
	;msgbox you will sac:`n---------------------`n`nname|`t`t|Sacrifice Qty|---|Owned Qty|`n%RunesToSacText%
	Gui, confirm:Add, Text,, DO YOU WANT TO SACRIFICE THESE RUNES?
	Gui, confirm:Add, edit, readonly vscroll h350 w290,---------------------`n`nName|-----------------|Sacrifice Qty|--------|Owned Qty|`n%RunesToSacText%
	gui, confirm:add,button,gconfirmyes vconfirmyes,YES
	gui, confirm:add,button,gconfirmno vconfirmno default,NO
	gui, confirm: Show, h450 w300, Rune Sacrifice Confirmation
	return
	
	confirmyes:
	Gui, confirm: submit,nohide
	Guicontrol, confirm:disable, confirmyes
	Guicontrol, confirm:disable, confirmno
	InputBox, confirmation, Confirmation, I'm about to sacrifice the runes you selected. This is irreversible. If you understand type the word sacrifice into this box now.
	if (confirmation != "sacrifice")
		gosub,confirmno
	else
		Sacrifice(RunesToSac)
	return
	
	confirmno:
	confirmguiclose:
	Gui, confirm: submit
	Gui, confirm: destroy
	RunesToSac := ""
	RunesToSkip := ""
	RunesToSacText := ""
	return
	
	ChecklistGuiSize: ; Expand/shrink in response to user's resizing of window.
		if (A_EventInfo = 1) ;window was minimized, do nothing.
			return 
		Anchor("LV","wh",1)
		Anchor("URL_Link1","y",1)
		WinSet, Redraw,, Rune Checklist
		return
	}
class Rune 
		{
		;=====CONSTRUCTOR=====
		__New(RuneType, Class, Race, ID, baseID, Name, Count, Rarity, Release, Factions) 
			{
			global AllRunes, ChampionsRunes, SpellsRunes, EquipmentRunes, RelicsRunes ;makes arrays accessible to this private class
			;---PROPERTIES---
			if !baseID
				return 0
			;msgbox % "instantiating new rune object with following properties: `n" . runetype . "`n" . name . "`ncount: " . count
			this.RuneType := RuneType
			this.Class := Class
			this.Race := Race
			this.ID := ID
			this.baseID := baseID
			this.Name := Name
			this.Count := Count
			this.Rarity := Rarity
			this.Release := Release
			this.Faction := Factions
			this.UniqueKey := baseid . RuneType
			this.place := 0
			AllRunes[this.UniqueKey] := this ;adds object to array "AllRunes" for tracking and ease of enumeration key is id
			%runeType%Runes[this.UniqueKey] := this
			;msgbox % "added unit faction" . AllRunes[id].faction . "to array AllRunes."
			}
		}
		
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}