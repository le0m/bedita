<form action="{$html->url('/users/saveGroup')}" method="post" name="groupForm" id="groupForm" class="cmxform">

<script type="text/javascript">
$(document).ready(function(){
	$(".indexlist TD").not(".checklist").not(".go").css("cursor","pointer").click(function(i) {
		document.location = $(this).parent().find("a:first").attr("href"); 
	} );
});
</script>


{assign var='p_name' value=$tr->t('name',true)}
{assign var='p_modified' value=$tr->t('modified',true)}
<table class="indexlist">
	<tr>
		<th>{$paginator->sort($p_name,'name')}</th>
		<th>{t}Access to Backend{/t}</th>
		<th style="text-align:center">{t}Users{/t}</th>
		<th>{$paginator->sort($p_modified,'modified')}</th>
		<th></th>
	</tr>
	{foreach from=$groups|default:'' item=g}
	<tr class="rowList {if ($g.Group.id == $group.Group.id)}on{/if}">	
		<td>
			<a href="{$html->url('/users/viewGroup/')}{$g.Group.id}">{$g.Group.name}</a>
		</td>
		<td>
			{if $g.Group.backend_auth}{t}Authorized{/t}{else}{t}Not Authorized{/t}{/if}
		</td>
		<td style="text-align:center">
			{$g.Group.num_of_users}
		</td>
		<td>{$g.Group.modified}</td>
		{if $g.Group.immutable or $module_modify != '1'}	
			<td style="text-align:center">
				<img title="{t}fixed object{/t}" src="{$html->webroot}img/iconFixed.png" style="margin-top:8px; height:12px;" />
			</td>
		{else}
			<td class="go" style="text-align:center">
				<input type="button" name="deleteGroup" value="{t}Delete{/t}" 
				onclick="javascript:delGroupDialog('{$g.Group.name}',{$g.Group.id});"/>
			</td>
		{/if}
		
	</tr>
  	{/foreach}
</table>

</form>