<%@ page contentType="text/html; charset=UTF-8" %>
<%@page import="java.lang.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="protocol.*"%>
<%@page import="com.goldhuman.auth.*"%>
<%@page import="org.apache.commons.logging.Log"%>
<%@page import="org.apache.commons.logging.LogFactory"%>
    <%@ page import="protocol.GRoleInventory" %>
    <%@ page import="com.goldhuman.IO.Protocol.Rpc.Data" %>
    <%@ page import="com.goldhuman.IO.Protocol.Rpc.Data.DataVector" %>
    <%@ page import="com.goldhuman.Common.Marshal.OctetsStream" %>
    <%@ page import="com.goldhuman.Common.Octets" %>
    <%@ page import="com.goldhuman.auth.*" %>
    <%@ page import="com.goldhuman.auth.AuthFilter" %>
    <%@ page import="com.goldhuman.service.interfaces.LogInfo" %>
    <%@ page import="com.goldhuman.service.interfaces.SimpleRoleBean" %>
    <%@ page import="com.goldhuman.service.interfaces.GMService" %>
    <%@ page import="com.goldhuman.service.GMServiceImpl" %>
    <%@ page import="com.goldhuman.util.LocaleUtil" %>
<%
String strRoleId = request.getParameter("roleid");
String strRoleName = request.getParameter("name");

LogFactory.getLog("modrole.jsp").info("request for roleid=" + strRoleId + ",name=" + strRoleName + ",operator=" + AuthFilter.getRemoteUser(session) );

int roleid = -1;
if( null != strRoleId && strRoleId.length() > 0 )
	roleid = Integer.parseInt(request.getParameter("roleid"));

if( -1 == roleid && null != strRoleName && strRoleName.length() > 0 )
{
	try{ roleid = GameDB.getRoleIdByName( strRoleName ); }
	catch (Exception e) { out.println(e.toString()); return; }
	if( -1 == roleid )
	{
		out.println(LocaleUtil.getMessage(request,"role_modrole_notsearchrole") + strRoleName + LocaleUtil.getMessage(request,"role_modrole_noroleortimeout") );
		return;
	}
}
if( -1 == roleid )
{
	out.println(LocaleUtil.getMessage(request,"role_modrole_inputidorname"));
	return;
}
RoleBean role = null;
try{
	role = GameDB.get( roleid );
	session.setAttribute("gamedb_rolebean", role);
	RoleBean xxrole = (RoleBean)session.getAttribute("gamedb_rolebean");
    out.println("TEST:"+xxrole.base.id);
}
catch (Exception e)
{       
	        LogFactory.getLog("modrole.jsp").info(", GameDB.get roleid=" + roleid  + e);
		        out.println("roleid=" + roleid + e.toString()); return;
}
if (null == role)
{
	out.println(LocaleUtil.getMessage(request,"role_modrole_retry"));
	return;
}
LogFactory.getLog("modrole.jsp").info("getRoleInfo, "+role.getLogString()+",operator=" + AuthFilter.getRemoteUser(session) );
String rolename;
switch( roleid )
{
	case 16:    rolename = LocaleUtil.getMessage(request,"role_modrole_wuxianan");	break;
	case 17:    rolename = LocaleUtil.getMessage(request,"role_modrole_wuxianv");	 break;
	case 18:    rolename = LocaleUtil.getMessage(request,"role_modrole_fashinan");	break;
	case 19:    rolename = LocaleUtil.getMessage(request,"role_modrole_fashinv");	break;
	case 20:    rolename = LocaleUtil.getMessage(request,"role_modrole_senlvnan");	break;
	case 21:    rolename = LocaleUtil.getMessage(request,"role_modrole_senlvnv");	break;
	case 22:    rolename = LocaleUtil.getMessage(request,"role_modrole_yaojinnan");	break;
	case 23:    rolename = LocaleUtil.getMessage(request,"role_modrole_yaojinnv");	break;
	case 24:    rolename = LocaleUtil.getMessage(request,"role_modrole_souyaonan");	break;
	case 25:    rolename = LocaleUtil.getMessage(request,"role_modrole_souyaonv");	break;
	case 26:    rolename = LocaleUtil.getMessage(request,"role_modrole_meilinnan");	break;
	case 27:    rolename = LocaleUtil.getMessage(request,"role_modrole_meilinv");	break;
	case 28:    rolename = LocaleUtil.getMessage(request,"role_modrole_yumannan");	break;
	case 29:    rolename = LocaleUtil.getMessage(request,"role_modrole_yumannv");	break;
	case 30:    rolename = LocaleUtil.getMessage(request,"role_modrole_yulinnan");	break;
	case 31:    rolename = LocaleUtil.getMessage(request,"role_modrole_yulinnv");	break;
	default:    rolename = LocaleUtil.getMessage(request,"role_modrole_putong");
}

String _tcomplete = (role.task.task_complete).toString();
String tcompletedb[] = _tcomplete.split("=");
String tcomplete = tcompletedb[1];

%>


<html>
<head>
<link href="../include/style.css" rel="stylesheet" type="text/css">
<title><%= LocaleUtil.getMessage(request,"role_modrole_title") %></title>
</head>

<body>
<%@include file="../include/header.jsp"%>
<table width="100%" height="350"  border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"><tr><td>

<form action="saverole.jsp" method="post">
<input type="hidden" name="roleid" value="<%=roleid%>">
<table width="80%" height="300" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="30" colspan="4" class="table_title"><%=rolename%>(roleid=<%=roleid%>)&nbsp;&nbsp;--&nbsp;<%= LocaleUtil.getMessage(request,"role_modrole_roleinitinfo") %></td>
  </tr>

  <tr>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_name") %>&nbsp;&nbsp;<%=StringEscapeUtils.escapeHtml(role.base.name.getString())%></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_race") %>&nbsp;&nbsp;<%=role.base.race%> <input type="text" name="race" value="<%=role.base.race%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_vocation") %>&nbsp;&nbsp;<%=RoleBean.ClsName(role.base.cls)%> <input type="text" name="cls" value="<%=role.base.cls%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_sex") %>&nbsp;&nbsp;<%=RoleBean.GenderName(role.base.gender)%></td>
  </tr>
  <tr>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_status") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=RoleBean.StatusName(role.base.status)%></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_deletime") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=role.base.delete_time<=0 ? "-" : (new SimpleDateFormat("y/M/d H:m:s")).format(new Date(1000*(long)role.base.delete_time))%></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_createtime") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=role.base.create_time<=0 ? "-" : (new SimpleDateFormat("y/M/d H:m:s")).format(new Date(1000*(long)role.base.create_time))%></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_lastlogintime") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=role.base.lastlogin_time<=0 ? "-" : (new SimpleDateFormat("y/M/d H:m:s")).format(new Date(1000*(long)role.base.lastlogin_time))%></td>
  </tr>
  <tr>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_world") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=role.status.worldtag%></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_redstatus") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=role.status.invader_state%></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_redtime") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=role.status.invader_time%></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_pinktime") %>&nbsp;&nbsp;&nbsp;&nbsp;<%=role.status.pariah_time%></td>
  </tr>
    <tr>
    <td height="20" colspan="3"><%= LocaleUtil.getMessage(request,"role_modrole_reputation") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="reputation" value="<%=role.status.reputation%>" size="12" maxlength="10"/>
    <br>Inventory size <input type="text" name="icapacity" value="<%=role.pocket.capacity%>" size="12" maxlength="10"/>
    <br>Storehouse size <input type="text" name="scapacity" value="<%=role.storehouse.capacity%>" size="12" maxlength="10"/>
    <br>Completed Task size <input type="text" name="taskcomplete" value="<%=tcomplete%>" size="12" maxlength="10"/>
    </td>
    <td height="20"><input type="checkbox" name="clearstorehousepasswd"><%= LocaleUtil.getMessage(request,"role_modrole_clearstorepass") %>
    <BR><input type="checkbox" name="test01"> Clear TASK
    <BR><input type="checkbox" name="test06"> Clear TASK inventories
    <BR><input type="checkbox" name="test02"> Clear equipment
    <BR><input type="checkbox" name="test03"> Clear pocket
    <BR><input type="checkbox" name="test04"> Clear storehouse
    <BR><input type="checkbox" name="test05"> Reset to L1 player
    &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr><td colspan="4">&nbsp;</td></tr>
        <%
            /*if(role.pocket.items != null)
			{
				Iterator itr = role.pocket.items.iterator();
				GRoleInventory grp;
				String label;
				int br = 0;
				while(itr.hasNext())
				{
				    grp = (GRoleInventory)itr.next();
				    try
					{
						out.println(grp.id);
						out.println(grp.data);
					}
					catch(Exception e)
					{
						out.println("Item not found");
					}
				}

			}
			*/
        %>
    <tr>
    <td height="20" colspan="3">
    Inventory List

    </td>
    <td height="20">
    </td>
    </tr>

    <tr><td colspan="4">&nbsp;</td></tr>
  <tr>
    <td height="20" colspan="1"><%= LocaleUtil.getMessage(request,"role_modrole_goldadd") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="cash_add" value="<%=role.user.cash_add%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="1"><%= LocaleUtil.getMessage(request,"role_modrole_goldbuy") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="cash_buy" value="<%=role.user.cash_buy%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="1"><%= LocaleUtil.getMessage(request,"role_modrole_goldsell") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="cash_sell" value="<%=role.user.cash_sell%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="1"><%= LocaleUtil.getMessage(request,"role_modrole_goldused") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="cash_used" value="<%=role.user.cash_used%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_level") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="level" value="<%=role.status.level%>" size="5" maxlength="3"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_xiuzhenjb") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="level2" value="<%=role.status.level2%>" size="5" maxlength="3"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_exp") %>&nbsp;&nbsp;<input type="text" name="exp" value="<%=role.status.exp%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_sp") %>&nbsp;&nbsp;<input type="text" name="sp" value="<%=role.status.sp%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_pp") %>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="pp" value="<%=role.status.pp%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_posx") %>&nbsp;<input type="text" name="posx" value="<%=(int)role.status.posx%>" size="5" maxlength="6"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_posy") %>&nbsp;<input type="text" name="posy" value="<%=(int)role.status.posy%>" size="5" maxlength="6"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_posz") %>&nbsp;<input type="text" name="posz" value="<%=(int)role.status.posz%>" size="5" maxlength="6"/></td>
  </tr>
  <tr>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_money")%>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="money" value="<%=role.pocket.money%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_vitality") %>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="vitality" value="<%=role.ep.vitality%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_energy") %>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="energy" value="<%=role.ep.energy%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_strength") %>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="strength" value="<%=role.ep.strength%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_agility") %>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="agility" value="<%=role.ep.agility%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_maxHP") %>&nbsp;<input type="text" name="max_hp" value="<%=role.ep.max_hp%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_maxMP") %>&nbsp;<input type="text" name="max_mp" value="<%=role.ep.max_mp%>" size="12" maxlength="10"/></td>
    <td height="20"><%= LocaleUtil.getMessage(request,"role_modrole_attack") %>&nbsp;&nbsp;<input type="text" name="attack" value="<%=role.ep.attack%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_damagelow") %>&nbsp;<input type="text" name="damage_low" value="<%=role.ep.damage_low%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_damagehigh") %>&nbsp;<input type="text" name="damage_high" value="<%=role.ep.damage_high%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_low") %>&nbsp;<input type="text" name="addon_damage_low0" value="<%=role.ep.addon_damage_low[0]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_high") %>&nbsp;<input type="text" name="addon_damage_high0" value="<%=role.ep.addon_damage_high[0]%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_low1") %>&nbsp;<input type="text" name="addon_damage_low1" value="<%=role.ep.addon_damage_low[1]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_high1") %>&nbsp;<input type="text" name="addon_damage_high1" value="<%=role.ep.addon_damage_high[1]%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_low2") %>&nbsp;<input type="text" name="addon_damage_low2" value="<%=role.ep.addon_damage_low[2]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_high2") %>&nbsp;<input type="text" name="addon_damage_high2" value="<%=role.ep.addon_damage_high[2]%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_low3") %>&nbsp;<input type="text" name="addon_damage_low3" value="<%=role.ep.addon_damage_low[3]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_high3") %>&nbsp;<input type="text" name="addon_damage_high3" value="<%=role.ep.addon_damage_high[3]%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_low4") %>&nbsp;<input type="text" name="addon_damage_low4" value="<%=role.ep.addon_damage_low[4]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_addon_damage_high4") %>&nbsp;<input type="text" name="addon_damage_high4" value="<%=role.ep.addon_damage_high[4]%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_damage_magic_low") %>&nbsp;<input type="text" name="damage_magic_low" value="<%=role.ep.damage_magic_low%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_damage_magic_high") %>&nbsp;<input type="text" name="damage_magic_high" value="<%=role.ep.damage_magic_high%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_resistance0") %>&nbsp;<input type="text" name="resistance0" value="<%=role.ep.resistance[0]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_resistance1") %>&nbsp;<input type="text" name="resistance1" value="<%=role.ep.resistance[1]%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_resistance2") %>&nbsp;<input type="text" name="resistance2" value="<%=role.ep.resistance[2]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrol_resistance3") %>&nbsp;<input type="text" name="resistance3" value="<%=role.ep.resistance[3]%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_resistance4") %>&nbsp;<input type="text" name="resistance4" value="<%=role.ep.resistance[4]%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_defense") %>&nbsp;<input type="text" name="defense" value="<%=role.ep.defense%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_armor") %>&nbsp;<input type="text" name="armor" value="<%=role.ep.armor%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2"><%= LocaleUtil.getMessage(request,"role_modrole_max_ap") %>&nbsp;<input type="text" name="max_ap" value="<%=role.ep.max_ap%>" size="12" maxlength="10"/></td>
  </tr>
  
  
  
  
  <tr>
    <td height="20" colspan="2">flight_speed&nbsp;<input type="text" name="flight_speed" value="<%=role.ep.flight_speed%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2">swim_speed&nbsp;<input type="text" name="swim_speed" value="<%=role.ep.swim_speed%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2">walk_speed&nbsp;<input type="text" name="walk_speed" value="<%=role.ep.walk_speed%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2">run_speed&nbsp;<input type="text" name="run_speed" value="<%=role.ep.run_speed%>" size="12" maxlength="10"/></td>
  </tr>
  <tr>
    <td height="20" colspan="2">hp_gen&nbsp;<input type="text" name="hp_gen" value="<%=role.ep.hp_gen%>" size="12" maxlength="10"/></td>
    <td height="20" colspan="2">mp_gen&nbsp;<input type="text" name="mp_gen" value="<%=role.ep.mp_gen%>" size="12" maxlength="10"/></td>
  </tr>
  
  
  <tr>
    <td height="50" align="center" colspan="4"> &nbsp;
    &nbsp;<font color=red><%= LocaleUtil.getMessage(request,"role_modrole_warning") %></font><br>
	<input type="submit" class="button" value="<%= LocaleUtil.getMessage(request,"role_modrole_save") %>" />&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="reset" class="button" value="<%= LocaleUtil.getMessage(request,"role_modrole_reset") %>" /></td>
  </tr>
</table>
</form>

</td></tr></table>
<%@include file="../include/foot.jsp"%>
</body>
</html>

