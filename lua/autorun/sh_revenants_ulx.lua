AddCSLuaFile()
local CATEGORY_NAME="Revenant's extensions"
local function init()
	loaded=true
	if ulx and ULib then
		print("loaded "..CATEGORY_NAME)
---------------------------------------------------------------
		function ulx.luaSend(calling_ply,target_plys,lua)
			for k,target_ply in ipairs(target_plys) do
				target_ply:SendLua(lua)
			end
			ulx.fancyLogAdmin( calling_ply, true, "#A ran lua #s on #T",lua,target_plys)
		end
		local luaSend = ulx.command( CATEGORY_NAME, "ulx luasend", ulx.luaSend, "!luasend", false, false, true )
		luaSend:addParam{type=ULib.cmds.PlayersArg}
		luaSend:addParam{ type=ULib.cmds.StringArg, hint="lua", ULib.cmds.takeRestOfLine }
		luaSend:defaultAccess( ULib.ACCESS_SUPERADMIN )
		luaSend:help( "Executes lua on the target's client. (Use '=' for output)" )
---------------------------------------------------------------
		function ulx.openscript_cl(calling_ply,target_ply,script)
			target_ply:SendLua([[include("]]..script..[[")]])
			ulx.fancyLogAdmin( calling_ply, "#A opened lua script #s on #T", script, target_ply)
		end
		local openscript_cl = ulx.command( CATEGORY_NAME, "ulx openscript_cl", ulx.openscript_cl, "!openscript_cl",false,false,true)
		openscript_cl:addParam{type=ULib.cmds.PlayerArg}
		openscript_cl:addParam{type=ULib.cmds.StringArg,hint="path relative to the lua folder",ULib.cmds.takeRestOfLine}
		openscript_cl:defaultAccess( ULib.ACCESS_ADMIN)
		openscript_cl:help( "open a lua script on target's client")
---------------------------------------------------------------
		function ulx.cancelauth(calling_ply,target_ply)
			if target_ply and target_ply:IsValid() then
			
				if target_ply:IsListenServerHost() then
					ULib.tsayError(calling_ply,"This player is immune to kicking",true)
					return
				end
				ulx.fancyLogAdmin( calling_ply, "#A Canceled the steam auth ticket of #T", target_ply,true,true )
				target_ply:Kick("Client left game (Steam auth ticket has been canceled)")
			end
		end
		local cancel_auth=ulx.command(CATEGORY_NAME,"ulx cancel_auth",ulx.cancelauth,"!cancel_auth",false,false,true )
		cancel_auth:addParam{type=ULib.cmds.PlayerArg}
		cancel_auth:defaultAccess(ULib.ACCESS_ADMIN)
		cancel_auth:help("cancel someone's steam authentication ticket")
---------------------------------------------------------------
		function ulx.forcemotd(calling_ply,target_ply)
			if target_ply and target_ply:IsValid() then
			
				ulx.fancyLogAdmin( calling_ply, "#A forced the MOTD on #T", target_ply,true,true )
				target_ply:SendLua([[RunConsoleCommand("ulx","motd")]])
			end
		end
		local forcemotd=ulx.command(CATEGORY_NAME,"ulx forcemotd",ulx.forcemotd,"!forcemotd",false,false,true )
		forcemotd:addParam{type=ULib.cmds.PlayerArg}
		forcemotd:defaultAccess(ULib.ACCESS_ADMIN)
		forcemotd:help("force a player to open the ulx motd")
---------------------------------------------------------------
		function ulx.crashkick( calling_ply, target_ply, reason )
			if target_ply:IsListenServerHost() then
				ULib.tsayError( calling_ply, "This player is immune to kicking", true )
				return
			end

			if reason and reason != "" and reason!="INSERT REASON HERE" then
				ulx.fancyLogAdmin( calling_ply, "#A crashed and kicked #T (#s)", target_ply, reason )
			else
				reason = nil
				ulx.fancyLogAdmin( calling_ply, "#A crashed and kicked #T", target_ply )
			end
			target_ply:SendLua("while true do cam.End3D() end")
			target_ply:SendLua("cam.End3D()")
			-- Delay by 1 frame to ensure the chat hook finishes with player intact. Prevents a crash.
			ULib.queueFunctionCall( ULib.kick, target_ply, reason, calling_ply )
		end
		local crash_kick = ulx.command( CATEGORY_NAME, "ulx crashkick", ulx.crashkick, "!crashkick" )
		crash_kick:addParam{ type=ULib.cmds.PlayerArg }
		crash_kick:addParam{ type=ULib.cmds.StringArg, hint="INSERT REASON HERE", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
		crash_kick:defaultAccess( ULib.ACCESS_SUPERADMIN)
		crash_kick:help("crashes the target, then kicks them")

		function ulx.crashban( calling_ply, target_ply, minutes, reason )
			if target_ply:IsListenServerHost() or target_ply:IsBot() then
				ULib.tsayError( calling_ply, "This player is immune to banning", true )
				return
			end

			local time = "for #s"
			if minutes == 0 then time = "permanently" end
			local str = "#A crashed and banned #T " .. time
			if reason and reason != "" and reason!="INSERT REASON HERE" then
				str = str .. " (#s)" 
			end
			ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )
			-- Delay by 1 frame to ensure any chat hook finishes with player intact. Prevents a crash.
			target_ply:SendLua("while true do cam.End3D() end")
			target_ply:SendLua("cam.End3D()")
			ULib.queueFunctionCall( ULib.kickban, target_ply, minutes, reason, calling_ply )
		end
		local crash_ban = ulx.command( CATEGORY_NAME, "ulx crashban", ulx.crashban, "!crashban", false, false, true )
		crash_ban:addParam{ type=ULib.cmds.PlayerArg }
		crash_ban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
		crash_ban:addParam{ type=ULib.cmds.StringArg, hint="INSERT REASON HERE", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
		crash_ban:defaultAccess(ULib.ACCESS_SUPERADMIN)
		crash_ban:help("crashes the target, then bans them." )
---------------------------------------------------------------
		local jailpos=Vector(0,0,0)

		if file.Exists("ulx_jailroom_pos/"..game.GetMap()..".txt","DATA") then
			data=util.JSONToTable(file.Read("ulx_jailroom_pos/"..game.GetMap()..".txt","DATA"))
			if data and data["x"] and data["y"] and data["z"] then
				jailpos=Vector(data["x"],data["y"],data["z"])
			end
		end


		function ulx.jailroomset(ply)
			if ply and ply:IsValid() and ply:IsPlayer() then
				local str="#A set the jailroom position for "..game.GetMap()
				ulx.fancyLogAdmin(ply,str)
				jailpos=ply:GetPos()
				file.CreateDir("ulx_jailroom_pos")
				local data={
					["x"]=jailpos.x,
					["y"]=jailpos.y,
					["z"]=jailpos.z,
				}
				file.Write("ulx_jailroom_pos/"..game.GetMap()..".txt",util.TableToJSON(data))
			else
				print"you cannot use the position of someone who is are everywhere and nowhere at the same time"
			end
		end
		local jailroomset=ulx.command(CATEGORY_NAME,"ulx jailroomset",ulx.jailroomset,"!jailroomset")
		jailroomset:defaultAccess(ULib.ACCESS_SUPERADMIN)
		jailroomset:help("set the position of the jailroom for the current map")


		function ulx.jailroom(ply,targets,seconds,reason,unjail)
			if unjail==false and reason and reason != "" and reason!="INSERT REASON HERE" then
				ulx.fancyLogAdmin(ply,"#A sent #T to the jailroom for #i seconds. Reason: #s",targets,seconds,reason)
				for k,v in pairs(targets) do
					JailRoom(v,seconds)
					v:SetNWString("ulxJailReason",reason)--set a networked string to show the reason
				end
			elseif unjail==false then
				ulx.fancyLogAdmin(ply,"#A sent #T to the jailroom for #i seconds. Reason: unspecified",targets,seconds)
				for k,v in pairs(targets) do
					JailRoom(v,seconds)
				end
			else
				ulx.fancyLogAdmin(ply,"#A released #T from the jailroom",target)
				for k,v in pairs(targets) do
					UnJail(v)
				end
			end
		end
		local jailroom=ulx.command(CATEGORY_NAME,"ulx jailroom",ulx.jailroom,"!jailroom")
		jailroom:addParam{type=ULib.cmds.PlayersArg}
		jailroom:addParam{type=ULib.cmds.NumArg,min=0,default=20,hint="seconds",ULib.cmds.round,ULib.cmds.optional}
		jailroom:addParam{type=ULib.cmds.StringArg,hint="INSERT REASON HERE",ULib.cmds.optional,ULib.cmds.takeRestOfLine}
		jailroom:addParam{type=ULib.cmds.BoolArg,invisible=true}
		jailroom:defaultAccess(ULib.ACCESS_ADMIN)
		jailroom:help("send player to the admin jailroom")
		jailroom:setOpposite("ulx unjailroom",{_,_,_,_,true},"!unjailroom")
		function JailRoom(ply,seconds)
			if ply.jailed then return end
			ply.jailed=true
			ply.timer=seconds
			--ply:KillSilent()
			
			ply:SetPos(jailpos)
			ply:StripWeapons()
			if timer.Exists(ply:SteamID64().."ulxJailTimer") then
				timer.Remove(ply:SteamID64().."ulxJailTimer")
			end
			ply:SetNWInt("ulxJailTimer",seconds)
			timer.Create(ply:SteamID64().."ulxJailTimer",1,seconds,function()
				if ply:IsValid() then
					local time_left=timer.RepsLeft(ply:SteamID64().."ulxJailTimer")
					ply:SetNWInt("ulxJailTimer",time_left)
					if time_left<1 then
						UnJail(ply)
					end
				end
			end)
		end

		function UnJail(ply)
			if ply.jailed then
				ply:SetNWInt("ulxJailTimer",0)
				ply:SetNWString("ulxJailReason","")
				ply.jailed=false
				timer.Remove(ply:SteamID64().."ulxJailTimer")
				ply:KillSilent()
				if DarkRP then
					DarkRP.notify(ply,2,8,"You have been unjailed")
				else
					ply:PrintMessage(HUD_PRINTTALK,"You have been unjailed")
				end
			end
		end

		if CLIENT then
			hook.Add("HUDPaint","jail_time_hud",function()
				local ply=LocalPlayer()
				local time_left=ply:GetNWInt("ulxJailTimer",0)
				local reason=ply:GetNWString("ulxJailReason","none given")
				if time_left>0 then
					draw.DrawText('you are jailed.\ntime left: '..time_left..'\nReason: '..reason.."\nDisconnecting will result in a BAN!","CloseCaption_Bold",ScrW()*0.5,ScrH()*0.425,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				end
			end)
		else
			hook.Add("PlayerNoClip","ulxBlockNoclipIfInJail",function(ply,desiredState)
				if desiredState==true and ply.jailed then
					return false
				end
			end)
			hook.Add("PlayerSpawn","ulxSpawnInJailIfDead",function(ply)
				if ply.jailed then
					timer.Simple(0,function()
						ply:SetPos(jailpos)
					end)
				end
			end)

			hook.Add("CanPlayerSuicide","ulxSuicedeCheck",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("PlayerSpawnProp","ulxBlockSpawnIfInJail",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("canBuyVehicle","ulxcanbuyveh",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("PlayerCanPickupWeapon","ulxcanuseswep",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("canBuyShipment","ulxcanbuyshipment",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("canBuyPistol","ulxcanbuypistol",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("canBuyCustomEntity","ulxcanbuyentity",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("canBuyAmmo","ulxcanbuyammo",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("PlayerCanPickupItem","ulxPickUpRest",function(ply)
				if ply.jailed then
					return false
				end
			end)
			hook.Add("PlayerDisconnected","ulxColumntIfNeed",function(ply)
				if ply.jailed and !ply:IsListenServerHost() then
					ULib.ban(ply,1440,"disconnecting while admin jailed")
					if DarkRP then
						DarkRP.notifyAll(1,4,"Player "..ply:Nick()..", ("..ply:SteamID()..") was banned for disconnecting while admin jailed")
					else
						PrintMessage(HUD_PRINTTALK,"Player "..ply:Nick()..", ("..ply:SteamID()..") was banned for disconnecting while admin jailed")
					end
				end
			end)
		end
---------------------------------------------------------------
		if !DarkRP and !engine.ActiveGamemode():lower():find("darkrp") then return end--for darkrp
		hook.Add("playerCanChangeTeam","cp_ban_check",function(ply,TEAM,force)
			if ply and TEAM and ply:IsPlayer() and GAMEMODE.CivilProtection[TEAM] then--is it a player trying to become a civil protection?
				local time=tonumber(ply:GetPData("cp_ban_list","0"))
				if time!=0 then
					if time>os.time() then
						if time-os.time()<604800 then--is there less that a week left?
							return false,DarkRP.getPhrase("have_to_wait", math.ceil(time-os.time()), "/"..RPExtraTeams[TEAM].command..", "..DarkRP.getPhrase("banned_or_demoted"))
						end
						return false,DarkRP.getPhrase("unable", "/"..RPExtraTeams[TEAM].command, DarkRP.getPhrase("banned_or_demoted"))
					end
					ply:SetPData("cp_ban_list","0")
				end
			end
		end)

		function ulx.cpunban(calling_ply,target_ply)
			local str = "#A unbanned #T from being civil protection"
			ulx.fancyLogAdmin( calling_ply, str, target_ply)
			target_ply:SetPData("cp_ban_list","0")
		end
		local cp_unban=ulx.command( CATEGORY_NAME, "ulx cpunban", ulx.cpunban, "!cpunban", false, false, true )
		cp_unban:addParam{ type=ULib.cmds.PlayerArg }
		cp_unban:defaultAccess(ULib.ACCESS_ADMIN)
		cp_unban:help("unbans target from civil protection.")

		function ulx.cpban( calling_ply, target_ply, minutes, reason )

			local time = "for #s"
			if minutes == 0 then time = "permanently" end
			local str = "#A banned #T from being civil protection " .. time
			if reason and reason != "" and reason!="INSERT REASON HERE" then
				str = str .. " (#s)" 
			end
			ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes != 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )

			if GAMEMODE.CivilProtection[target_ply:Team()] then--are they a civil protection?
				target_ply:changeTeam(GAMEMODE.DefaultTeam,true,true)--set them to the default team if so
			end

			if tobool(minutes) then
				target_ply:SetPData("cp_ban_list",os.time()+minutes*60)
			else
				target_ply:SetPData("cp_ban_list",os.time()+9972201600)--316 years is a long time
			end
		end
		local cp_ban = ulx.command( CATEGORY_NAME, "ulx cpban", ulx.cpban, "!cpban", false, false, true )
		cp_ban:addParam{ type=ULib.cmds.PlayerArg }
		cp_ban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 means permanently", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
		cp_ban:addParam{ type=ULib.cmds.StringArg, hint="INSERT REASON HERE", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
		cp_ban:defaultAccess(ULib.ACCESS_ADMIN)
		cp_ban:help("bans target from civil protection." )
---------------------------------------------------------------
	else
		print"ULX and ULib MUST be installed"
	end
end

hook.Add("Initialize",CATEGORY_NAME,init)
local loaded
if loaded then init() end