local CATEGORY_NAME="Revenant's extensions"
local init=function()
	if ulx and ULib then
		print("loading "..CATEGORY_NAME)
--[ [-----------------------------------------------------
		local luaSend = ulx.command(CATEGORY_NAME,"ulx luasend",function(calling_ply,target_plys,lua)
			for k,target_ply in ipairs(target_plys) do
				net.Start("ulx luasend")
				net.WriteString(lua)
				net.Send(target_ply)
			end
			ulx.fancyLogAdmin(calling_ply,true,"#A ran lua #s on #T",lua,target_plys)
		end,"!luasend",false,false,true)
		luaSend:addParam{type=ULib.cmds.PlayersArg}
		luaSend:addParam{ type=ULib.cmds.StringArg,hint="lua",ULib.cmds.takeRestOfLine }
		luaSend:defaultAccess(ULib.ACCESS_SUPERADMIN)
		luaSend:help("Executes lua on the target's client. (Use '=' for output)")
		if SERVER then
			util.AddNetworkString("ulx luasend")
		else
			net.Receive("ulx luasend",function(len,ply)
				RunString(net.ReadString(),"ulx luasend")
			end)
		end
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local openscript_cl = ulx.command(CATEGORY_NAME,"ulx openscript_cl",function(calling_ply,target_ply,script)
			target_ply:SendLua("include('"..script.."')")
			ulx.fancyLogAdmin(calling_ply,"#A opened lua script #s on #T",script,target_ply)
		end,"!openscript_cl",false,false,true)
		openscript_cl:addParam{type=ULib.cmds.PlayerArg}
		openscript_cl:addParam{type=ULib.cmds.StringArg,hint="path relative to the lua folder",ULib.cmds.takeRestOfLine}
		openscript_cl:defaultAccess(ULib.ACCESS_ADMIN)
		openscript_cl:help("open a lua script on target's client")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local GetCommandTable = ulx.command(CATEGORY_NAME,"ulx getcommandtable",function(calling_ply,target_ply)
			if target_ply:IsBot() then
				ULib.tsayError(calling_ply,"This player is actually a bot, there's no clientside commands to check",true)
			elseif target_ply:IsTimingOut() then
				ULib.tsayError(calling_ply,"This player is timing out, their client will not reply",true)
			elseif !target_ply:IsConnected() then
				ULib.tsayError(calling_ply,"This player hasn't finished joining, there's no clientside commands to check",true)
			elseif target_ply.GetCommandTable then
				ULib.tsayError(calling_ply,"the client is being checked by someone else",true)
			else
				target_ply.GetCommandTable=calling_ply
				target_ply:SendLua("getcommandtable_start()")
				timer.Simple(5,function()
					if target_ply.GetCommandTable then
						if calling_ply and calling_ply:IsValid() then
							ULib.tsayError(calling_ply,"the client has failed to reply, you should probably investigate further",true)
						end
						target_ply.GetCommandTable=nil
					end
				end)
				ulx.fancyLogAdmin(calling_ply,true,"#A requested #T's commandtable",target_ply)
			end
		end,"!getcommandtable",false,false,true)
		GetCommandTable:addParam{type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		GetCommandTable:defaultAccess(ULib.ACCESS_ADMIN)
		GetCommandTable:help("get a player's commandtable")
		if SERVER then
			util.AddNetworkString'ulxgetcommandtable'
		else
			getcommandtable_start=function()
				local commandtable,autocompletes=concommand.GetTable()
				local reply={}
				for name,func in SortedPairs(commandtable) do
					reply[name]=true
				end
				net.Start"ulxgetcommandtable"
				net.WriteTable(reply)
				net.SendToServer()
			end
		end
		if SERVER then
			net.Receive("ulxgetcommandtable",function(len,target_ply)
				local calling_ply=target_ply.GetCommandTable
				if calling_ply then
					target_ply.GetCommandTable=nil
					local reply=net.ReadTable()
					if reply then
						net.Start"ulxgetcommandtable"
						net.WriteTable(reply)
						net.WriteEntity(target_ply)
						net.Send(calling_ply)
					end
				end
			end)
		else
			net.Receive("ulxgetcommandtable",function(len,target_ply)
				local target_commandtable=net.ReadTable()
				local my_commandtable={}
				local commandtable,autocompletes=concommand.GetTable()
				local target_ply=net.ReadEntity()
				for name,func in SortedPairs(commandtable) do
					if target_commandtable[name] then
						target_commandtable[name]=nil
					else
						my_commandtable[name]=true
					end
				end
				local tstr="console commands found on the target that aren't on your client:\n"
				for k,v in SortedPairs(target_commandtable)do
					tstr=tstr.."\tcommand="..k.."\n"
				end
				print(tstr)
				local mstr="console commands found on your client that aren't on the target:\n"
				for k,v in SortedPairs(my_commandtable)do
					mstr=mstr.."\tcommand="..k.."\n"
				end
				print(mstr)
			end)
		end
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local GetHookTable=ulx.command(CATEGORY_NAME,"ulx gethooktable",function(calling_ply,target_ply)
			if target_ply:IsBot() then
				ULib.tsayError(calling_ply,"This player is actually a bot, there's no clientside hooks to check",true)
			elseif target_ply:IsTimingOut() then
				ULib.tsayError(calling_ply,"This player is timing out, their client will not reply",true)
			elseif !target_ply:IsConnected() then
				ULib.tsayError(calling_ply,"This player hasn't finished joining, there's no clientside hooks to check",true)
			elseif target_ply.GetHookTable then
				ULib.tsayError(calling_ply,"the client is being checked by someone else",true)
			else
				target_ply.GetHookTable=calling_ply
				target_ply:SendLua("gethooktable_start()")
				timer.Simple(5,function()
					if target_ply.GetHookTable then
						if calling_ply and calling_ply:IsValid() then
							ULib.tsayError(calling_ply,"the client has failed to reply, you should probably investigate further",true)
						end
						target_ply.GetHookTable=nil
					end
				end)
				ulx.fancyLogAdmin(calling_ply,true,"#A requested #T's hooktable",target_ply)
			end
		end,"!gethooktable",false,false,true)
		GetHookTable:addParam{type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		GetHookTable:defaultAccess(ULib.ACCESS_ADMIN)
		GetHookTable:help("get a player's hooktable")
		if SERVER then
			util.AddNetworkString'ulxgethooktable'
		else
			gethooktable_start=function()
				local hooktable=hook.GetTable()
				local reply={}
				for event,tbl in SortedPairs(hooktable) do
					for name,func in pairs(tbl) do
						reply[event..",name="..tostring(name)]=true
					end
				end
				net.Start"ulxgethooktable"
				net.WriteTable(reply)
				net.SendToServer()
			end
		end
		if SERVER then
			net.Receive("ulxgethooktable",function(len,target_ply)
				local calling_ply=target_ply.GetHookTable
				if calling_ply then
					target_ply.GetHookTable=nil
					local reply=net.ReadTable()
					if reply then
						net.Start"ulxgethooktable"
						net.WriteTable(reply)
						net.WriteEntity(target_ply)
						net.Send(calling_ply)
					end
				end
			end)
		else
			net.Receive("ulxgethooktable",function(len,target_ply)
				local target_hooktable=net.ReadTable()
				local my_hooktable={}
				local target_ply=net.ReadEntity()
				for event,names in SortedPairs(hook.GetTable()) do
					for name,func in pairs(names) do
						name=tostring(name)
						if target_hooktable[event..",name="..name] then
							target_hooktable[event..",name="..name]=nil
						else
							my_hooktable[event..",name="..name]=true
						end
					end
				end
				local tstr="hooks found on the target that aren't on your client:\n"
				for k,v in SortedPairs(target_hooktable)do
					tstr=tstr.."\tevent="..k.."\n"
				end
				print(tstr)
				local mstr="hooks found on your client that aren't on the target:\n"
				for k,v in SortedPairs(my_hooktable)do
					mstr=mstr.."\tevent="..k.."\n"
				end
				print(mstr)
			end)
		end
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local memory_leak = ulx.command(CATEGORY_NAME,"ulx memoryleak",function(calling_ply,target_ply)
			ulx.fancyLogAdmin(calling_ply,true,"#A started a memory leak on #T",target_ply)
			target_ply:SendLua("local tbl={}hook.Add('Think','crash',function()local t={}for i=1,999999 do t[i]=i end tbl[CurTime()]=t end)")
		end,"!memory_leak",false,false,true)
		memory_leak:addParam{type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		memory_leak:defaultAccess(ULib.ACCESS_SUPERADMIN)
		memory_leak:help("slowly crash a client via memory leak")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local cancel_auth=ulx.command(CATEGORY_NAME,"ulx cancel_auth",function(calling_ply,target_ply)
			if target_ply and target_ply:IsValid() then
				if target_ply:IsListenServerHost() then
					ULib.tsayError(calling_ply,"This player is immune to kicking",true)
					return
				end
				ulx.fancyLogAdmin(calling_ply,"#A Canceled the steam auth ticket of #T",target_ply,true,true)
				target_ply:Kick("Client left game (Steam auth ticket has been canceled)")
			end
		end,"!cancel_auth",false,false,true)
		cancel_auth:addParam{type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		cancel_auth:defaultAccess(ULib.ACCESS_ADMIN)
		cancel_auth:help("cancel someone's steam authentication ticket")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local forcemotd=ulx.command(CATEGORY_NAME,"ulx forcemotd",function(calling_ply,target_ply)
			if target_ply and target_ply:IsValid() then
			
				ulx.fancyLogAdmin(calling_ply,"#A forced the MOTD on #T",target_ply,true,true)
				target_ply:SendLua("RunConsoleCommand('ulx','motd')")
			end
		end,"!forcemotd",false,false,true)
		forcemotd:addParam{type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		forcemotd:defaultAccess(ULib.ACCESS_ADMIN)
		forcemotd:help("force a player to open the ulx motd")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local clearpac=ulx.command(CATEGORY_NAME,"ulx clearpac",function(calling_ply,target_ply)
			if target_ply and target_ply:IsValid() then
			
				ulx.fancyLogAdmin(calling_ply,"#A cleared #T's PAC3",target_ply,true,true)
				target_ply:SendLua("RunConsoleCommand('pac_clear_parts')")
			end
		end,"!clearpac",false,false,true)
		clearpac:addParam{type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		clearpac:defaultAccess(ULib.ACCESS_ADMIN)
		clearpac:help("forcibly clear a player's PAC3")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local nukelaws=ulx.command(CATEGORY_NAME,"ulx nukelaws",function(ply)
			hook.Run("resetLaws",ply)
			DarkRP.resetLaws()
			DarkRP.notify(ply,0,2,DarkRP.getPhrase("law_reset"))
			ulx.fancyLogAdmin(ply,"#A forcibly reset all laws",true,true)
		end,"!nukelaws",false,false,true)
		nukelaws:defaultAccess(ULib.ACCESS_ADMIN)
		nukelaws:help("forcibly reset all laws")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local crash_kick = ulx.command(CATEGORY_NAME,"ulx crashkick",function(calling_ply,target_ply,reason)
			if target_ply:IsListenServerHost() then
				ULib.tsayError(calling_ply,"This player is immune to kicking",true)
				return
			end

			if reason and reason != "" and reason!="INSERT REASON HERE" then
				ulx.fancyLogAdmin(calling_ply,"#A crashed and kicked #T (#s)",target_ply,reason)
			else
				reason = nil
				ulx.fancyLogAdmin(calling_ply,"#A crashed and kicked #T",target_ply)
			end
			target_ply:SendLua("while true do cam.End3D() end")
			target_ply:SendLua("cam.End3D()")
			-- Delay by 1 frame to ensure the chat hook finishes with player intact. Prevents a crash.
			ULib.queueFunctionCall(ULib.kick,target_ply,reason,calling_ply)
		end,"!crashkick")
		crash_kick:addParam{ type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		crash_kick:addParam{ type=ULib.cmds.StringArg,hint="INSERT REASON HERE",ULib.cmds.optional,ULib.cmds.takeRestOfLine,completes=ulx.common_kick_reasons }
		crash_kick:defaultAccess(ULib.ACCESS_SUPERADMIN)
		crash_kick:help("crashes the target, then kicks them")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local crash_ban = ulx.command(CATEGORY_NAME,"ulx crashban",function(calling_ply,target_ply,minutes,reason)
			if target_ply:IsListenServerHost() or target_ply:IsBot() then
				ULib.tsayError(calling_ply,"This player is immune to banning",true)
				return
			end

			local time = "for #s"
			if minutes == 0 then time = "permanently" end
			local str = "#A crashed and banned #T " .. time
			if reason and reason != "" and reason!="INSERT REASON HERE" then
				str = str .. " (#s)" 
			end
			ulx.fancyLogAdmin(calling_ply,str,target_ply,minutes ~= 0 and ULib.secondsToStringTime(minutes * 60) or reason,reason)
			-- Delay by 1 frame to ensure any chat hook finishes with player intact. Prevents a crash.
			target_ply:SendLua("cam.End()")
			ULib.queueFunctionCall(ULib.kickban,target_ply,minutes,reason,calling_ply)
		end,"!crashban",false,false,true)
		crash_ban:addParam{ type=ULib.cmds.PlayerArg,ULib.cmds.ignoreCanTarget}
		crash_ban:addParam{ type=ULib.cmds.NumArg,hint="minutes, 0 for perma",ULib.cmds.optional,ULib.cmds.allowTimeString,min=0 }
		crash_ban:addParam{ type=ULib.cmds.StringArg,hint="INSERT REASON HERE",ULib.cmds.optional,ULib.cmds.takeRestOfLine,completes=ulx.common_kick_reasons }
		crash_ban:defaultAccess(ULib.ACCESS_SUPERADMIN)
		crash_ban:help("crashes the target, then bans them.")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local jailpos=Vector(0,0,0)
		if file.Exists("ulx_jailroom_pos/"..game.GetMap()..".txt","DATA") then
			data=util.JSONToTable(file.Read("ulx_jailroom_pos/"..game.GetMap()..".txt","DATA"))
			if data then
				jailpos=Vector(data.x or 0,data.y or 0,data.z or 0)
			end
		end
		local jailroomset=ulx.command(CATEGORY_NAME,"ulx jailroomset",function(ply)
			if ply:IsValid() then
				ulx.fancyLogAdmin(ply,"#A set the jailroom position for "..game.GetMap())
				jailpos=ply:GetPos()
				file.CreateDir("ulx_jailroom_pos")
				file.Write("ulx_jailroom_pos/"..game.GetMap()..".txt",util.TableToJSON({
					x=jailpos.x,
					y=jailpos.y,
					z=jailpos.z,
				},true))
			else
				print"you cannot use the position of someone who is are everywhere and nowhere at the same time"
			end
		end,"!jailroomset")
		jailroomset:defaultAccess(ULib.ACCESS_SUPERADMIN)
		jailroomset:help("set the position of the jailroom for the current map")
--]]-----------------------------------------------------
--[ [-----------------------------------------------------
		local UnJail=function(ply)
			if ply.jailed then
				ply.jailed=false
				ply:SetNWFloat("ulxJailTimer",0)
				ply:SetNWString("ulxJailReason","")
				timer.Remove(ply:SteamID64().."ulxJailTimer")
				ply:SendLua("LocalPlayer().jailed=nil")
				timer.Simple(0,function()
					if ply:IsValid() then
						ply:Spawn()
						ply:SetCollisionGroup(ply.OldCollisionGroup or COLLISION_GROUP_PLAYER)
						ply.OldCollisionGroup=nil
						ply:CollisionRulesChanged()
					end
				end)
				if DarkRP then
					DarkRP.notify(ply,2,8,"You have been unjailed")
				end
				ply:SendLua("LocalPlayer().jailed=nil")
				ply:PrintMessage(HUD_PRINTTALK,"You have been unjailed")
			end
		end
		local jailroom=ulx.command(CATEGORY_NAME,"ulx jailroom",function(ply,targets,seconds,reason,unjail)
			if unjail then
				ulx.fancyLogAdmin(ply,"#A released #T from the jailroom",targets)
				for k,v in pairs(targets) do
					UnJail(v)
				end
			else
				if !reason or reason==""or reason=="INSERT REASON HERE"or reason=="[ { INSERT REASON HERE } ]"then
					reason="unspecified"
				end
				ulx.fancyLogAdmin(ply,"#A sent #T to the jailroom for #i seconds. Reason: #s",targets,seconds,reason)
				for k,v in pairs(targets) do
					if v.jail and v.jail.unjail then
						v.jail.unjail()
					end
					if !v.jailed then
						v.jailed=true
						v.timer=seconds
						v:Spawn()
						v:SetPos(jailpos)
						v.OldCollisionGroup=v.OldCollisionGroup or v:GetCollisionGroup()
						v:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
						v:SetCustomCollisionCheck(true)
						v:CollisionRulesChanged()
						v:SendLua("LocalPlayer().jailed=true")
						v:SetNWString("ulxJailReason",reason)--set a networked string to show the reason
						v:SetNWFloat("ulxJailTimer",seconds+CurTime())
						timer.Create(v:SteamID64().."ulxJailTimer",seconds,1,function()
							if v:IsValid() and v.jailed then
								UnJail(v)
							end
						end)
					else
						v:SetNWString("ulxJailReason",reason)--set a networked string to show the reason
						v:SetNWFloat("ulxJailTimer",seconds+CurTime())
						timer.Create(v:SteamID64().."ulxJailTimer",seconds,1,function()
							if v:IsValid() and v.jailed then
								UnJail(v)
							end
						end)
					end
				end
			end
		end,"!jailroom")
		jailroom:addParam{type=ULib.cmds.PlayersArg,ULib.cmds.ignoreCanTarget}
		jailroom:addParam{type=ULib.cmds.NumArg,min=0,default=20,hint="seconds",ULib.cmds.round,ULib.cmds.optional}
		jailroom:addParam{type=ULib.cmds.StringArg,hint="INSERT REASON HERE",ULib.cmds.optional,ULib.cmds.takeRestOfLine}
		jailroom:addParam{type=ULib.cmds.BoolArg,invisible=true}
		jailroom:defaultAccess(ULib.ACCESS_ADMIN)
		jailroom:help("send player to the admin jailroom")
		jailroom:setOpposite("ulx unjailroom",{_,_,_,_,true},"!unjailroom")

		hook.Add("canBuyAmmo","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("canBuyCustomEntity","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("canBuyPistol","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("canBuyShipment","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("canBuyVehicle","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("CanPlayerEnterVehicle","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("CanPlayerSuicide","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("EntityTakeDamage","ulxjailroom",function(ply,CTakeDamageInfo)
			if ply.jailed then
				CTakeDamageInfo:SetDamage(0)
				CTakeDamageInfo:SetDamageType(DMG_FALL)
				return true
			end
		end)
		hook.Add("HUDPaint","ulxjailroom",function()
			local ply=LocalPlayer()
			local reason=ply:GetNWString("ulxJailReason","")
			if reason==""then return end
			local time_left=ply:GetNWFloat("ulxJailTimer",0)-CurTime()
			if time_left>0 then
				draw.DrawText('you are jailed.\ntime left: '..(math.Round(time_left,2)+math.random(1,9)*0.001)..'\nReason: '..reason.."\nDisconnecting will result in a BAN!","CloseCaption_Bold",ScrW()*0.5,ScrH()*0.425,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			end
		end)
		hook.Add("PlayerCanPickupItem","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("PlayerCanPickupWeapon","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		hook.Add("PlayerNoClip","ulxjailroom",function(ply,desiredState)
			if desiredState and ply.jailed then
				return false
			end
		end)
		hook.Add("PlayerSpawn","ulxjailroom",function(ply)
			if ply.jailed then
				timer.Simple(0,function()
					ply:SetPos(jailpos)
				end)
				timer.Simple(0.01,function()
					ply:SetPos(jailpos)
				end)
				timer.Simple(0.1,function()
					ply:SetPos(jailpos)
				end)
				timer.Simple(0.11,function()
					ply:SetPos(jailpos)
				end)
			end
		end)
		hook.Add("PlayerSpawnProp","ulxjailroom",function(ply)
			if ply.jailed then
				return false
			end
		end)
		if SERVER then
			gameevent.Listen("player_disconnect")
			hook.Add("player_disconnect","ulxjailroom",function(data)
				local ply=Player(data.userid)--get the player by their userid
				if ply and ply:IsValid() and ply.jailed and !ply:IsListenServerHost() then--is this a player entity that we can ban?
					local reason=data.reason:lower()--get the reason for the disconnection
					if reason=="disconnect by user" then--the actually DCed while jailled
						ULib.ban(ply,1440,"disconnecting while admin jailed("..ply:GetNWString("ulxJailReason","")..")")--add their ban
						if DarkRP then
							DarkRP.notifyAll(1,4,ply:Nick()..", ("..ply:SteamID()..") was banned for disconnecting while admin jailed :'(")
						end
						PrintMessage(HUD_PRINTTALK,ply:Nick()..", ("..ply:SteamID()..") was banned for disconnecting while admin jailed :'(")
					end
				end
			end)
		end
		hook.Add("ShouldCollide","ulxjailroom",function(a,b)
			if a and b and a:IsValid() and b:IsValid() and a:IsPlayer() and b:IsPlayer() then
				if a.jailed or b.jailed then
					return false
				end
			end
		end)
		hook.Add("StartCommand","ulxjailroom",function(ply,CUserCmd)
			if ply.jailed then
				CUserCmd:RemoveKey(IN_ATTACK)
				CUserCmd:RemoveKey(IN_ATTACK2)
				CUserCmd:RemoveKey(IN_RELOAD)
			end
		end)

--]]-----------------------------------------------------
	else
		print"ULX and ULib MUST be installed"
	end
end
hook.Add("Initialize",CATEGORY_NAME.."MAIN",init)
if player.GetAll()[1] or GAMEMODE and GAMEMODE.Config then init() end