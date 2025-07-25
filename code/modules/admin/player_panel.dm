
/datum/admins/proc/player_panel_new()//The new one
	if (!check_rights_for(usr.client, R_HOLDER))
		return
	var/ui_scale = owner.prefs.read_preference(/datum/preference/toggle/ui_scale)
	var/dat = "<html><head><title>Admin Player Panel</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			[!ui_scale && owner.window_scaling ? "<style>body {zoom: [100 / owner.window_scaling]%;}</style>" : ""]
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByClassName("bold");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,job,name,real_name,image,key,ip,antagonist,ref){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b></font>"

					body += "</td><td align='center'>";

					body += "<a href='byond://?src=\ref[src];[HrefToken()];adminplayeropts="+ref+"'>PP</a> - "
					body += "<a href='byond://?src=\ref[src];[HrefToken()];notes=show;mob="+ref+"'>N</a> - "
					body += "<a href='byond://?_src_=vars;Vars="+ref+"'>VV</a> - "
					body += "<a href='byond://?src=\ref[src];[HrefToken()];traitor="+ref+"'>TP</a> - "
					body += "<a href='byond://?src=\ref[usr];[HrefToken()];priv_msg=\ref"+ref+"'>PM</a> - "
					body += "<a href='byond://?src=\ref[src];[HrefToken()];subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='byond://?src=\ref[src];[HrefToken()];adminplayerobservejump="+ref+"'>JMP</a><br>"
					if(antagonist > 0)
						body += "<font size='2'><a href='byond://?src=\ref[src];[HrefToken()];check_antagonist=1'><font color='red'><b>Antagonist</b></font></a></font>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");
						if(!id)
							continue;

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					"} + span_giant(span_bold("Player panel")) + {"<br>
					Hover over a line to see more information - <a href='byond://?src=\ref[src];[HrefToken()];check_antagonist=1'>Check antagonists</a>
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					"} + span_bold("Search:") + {" <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sort_mobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey)

			var/color = "#e6e6e6"
			if(i%2 == 0)
				color = "#f2f2f2"
			var/is_antagonist = is_special_character(M)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(ishuman(M))
						M_job = M.job
					else if(isslime(M))
						M_job = JOB_SLIME
					else if(issmall(M))
						M_job = JOB_MONKEY
					else if(isalien(M))
						M_job = JOB_ALIEN
					else
						M_job = JOB_CARBON_BASED

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = JOB_AI
					else if(ispAI(M))
						M_job = JOB_PAI
					else if(isrobot(M))
						M_job = JOB_CYBORG
					else
						M_job = JOB_SILICON_BASED

				else if(isanimal(M)) //simple animals
					if(iscorgi(M))
						M_job = JOB_CORGI
					else
						M_job = JOB_ANIMAL

				else
					M_job = JOB_LIVING

			else if(isnewplayer(M))
				M_job = JOB_NEW_PLAYER

			else if(isobserver(M))
				M_job = JOB_GHOST

			M_job = replacetext(M_job, "'", "")
			M_job = replacetext(M_job, "\"", "")
			M_job = replacetext(M_job, "\\", "")

			var/M_name = M.name
			M_name = replacetext(M_name, "'", "")
			M_name = replacetext(M_name, "\"", "")
			M_name = replacetext(M_name, "\\", "")
			var/M_rname = M.real_name
			M_rname = replacetext(M_rname, "'", "")
			M_rname = replacetext(M_rname, "\"", "")
			M_rname = replacetext(M_rname, "\\", "")

			var/M_key = M.key
			M_key = replacetext(M_key, "'", "")
			M_key = replacetext(M_key, "\"", "")
			M_key = replacetext(M_key, "\\", "")

			//output for each mob
			dat += {"

				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","--unused--","[M_key]","[M.lastKnownIP]",[is_antagonist],"\ref[M]")'
						>
						<span id='search[i]'>"} + span_bold("[M_name] - [M_rname] - [M_key] ([M_job])") + {"</span>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>

			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	var/window_size = "size=600x480"
	if(owner.window_scaling && ui_scale)
		window_size = "size=[600 * owner.window_scaling]x[400 * owner.window_scaling]"
	usr << browse(dat, "window=players;[window_size]")

//The old one
/datum/admins/proc/player_panel_old()
	if (!check_rights_for(usr.client, R_HOLDER))
		return

	var/dat = "<html><head><title>Player Menu</title></head>"
	dat += "<body><table border=1 cellspacing=5>" + span_bold("<tr><th>Name</th><th>Real Name</th><th>Assigned Job</th><th>Key</th><th>Options</th><th>PM</th><th>Traitor?</th></tr>")
	//add <th>IP:</th> to this if wanting to add back in IP checking
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = sort_mobs()

	for(var/mob/M in mobs)
		if(!M.ckey) continue

		dat += "<tr><td>[M.name]</td>"
		if(isAI(M))
			dat += "<td>AI</td>"
		else if(isrobot(M))
			dat += "<td>Cyborg</td>"
		else if(ishuman(M))
			dat += "<td>[M.real_name]</td>"
		else if(ispAI(M))
			dat += "<td>pAI</td>"
		else if(isnewplayer(M))
			dat += "<td>New Player</td>"
		else if(isobserver(M))
			dat += "<td>Ghost</td>"
		else if(issmall(M))
			dat += "<td>Monkey</td>"
		else if(isalien(M))
			dat += "<td>Alien</td>"
		else
			dat += "<td>Unknown</td>"


		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.assigned_role)
				dat += "<td>[H.mind.assigned_role]</td>"
		else
			dat += "<td>NA</td>"


		dat += {"<td>[M.key ? (M.client ? M.key : "[M.key] (DC)") : "No key"]</td>
		<td align=center><A href='byond://?src=\ref[src];[HrefToken()];adminplayeropts=\ref[M]'>X</A></td>
		<td align=center><A href='byond://?src=\ref[usr];[HrefToken()];priv_msg=\ref[M]'>PM</A></td>
		"}

		if(usr.client)
			switch(is_special_character(M))
				if(0)
					dat += {"<td align=center><A href='byond://?src=\ref[src];[HrefToken()];traitor=\ref[M]'>Traitor?</A></td>"}
				if(1)
					dat += {"<td align=center><A href='byond://?src=\ref[src];[HrefToken()];traitor=\ref[M]'>"} + span_red("Traitor?") + {"</A></td>"}
				if(2)
					dat += {"<td align=center><A href='byond://?src=\ref[src];[HrefToken()];traitor=\ref[M]'>"} + span_red(span_bold("Traitor?")) + {"</A></td>"}
		else
			dat += {"<td align=center> N/A </td>"}



	dat += "</table></body></html>"

	usr << browse(dat, "window=players;size=640x480")



/datum/admins/proc/check_antagonists()
	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		var/dat = "<html><head><title>Round Status</title></head><body><h1>" + span_bold("Round Status") + "</h1>"
		dat += "Current Game Mode: " + span_bold("[ticker.mode.name]") + "<BR>"
		dat += "Round Duration: " + span_bold("[roundduration2text()]") + "<BR>"
		dat += span_bold("Emergency shuttle") + "<BR>"
		if (!emergency_shuttle.online())
			dat += "<a href='byond://?src=\ref[src];[HrefToken()];call_shuttle=1'>Call Shuttle</a><br>"
		else
			if (emergency_shuttle.wait_for_launch)
				var/timeleft = emergency_shuttle.estimate_launch_time()
				dat += "ETL: <a href='byond://?src=\ref[src];[HrefToken()];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"

			else if (emergency_shuttle.shuttle.has_arrive_time())
				var/timeleft = emergency_shuttle.estimate_arrival_time()
				dat += "ETA: <a href='byond://?src=\ref[src];[HrefToken()];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
				dat += "<a href='byond://?src=\ref[src];[HrefToken()];call_shuttle=2'>Send Back</a><br>"

			if (emergency_shuttle.shuttle.moving_status == SHUTTLE_WARMUP)
				dat += "Launching now..."

		dat += "<a href='byond://?src=\ref[src];[HrefToken()];delay_round_end=1'>[ticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		dat += "<hr>"
		for(var/antag_type in GLOB.all_antag_types)
			var/datum/antagonist/A = GLOB.all_antag_types[antag_type]
			dat += A.get_check_antag_output(src)
		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=400x500")
	else
		tgui_alert_async(usr, "The game hasn't started yet!")
