{*
Template incluso.
Menu a SX valido per tutte le pagine del controller.
*}

{assign var='method' value=$method|default:'index'}

<div class="primacolonna">
	
	<div class="modules"><label class="bedita" rel="{$html->url('/')}">BEdita 3.0</label></div>

	{include file="../common_inc/messages.tpl"}
	
	<ul class="insidecol">
			<li {if $method eq 'index'}class="on"{/if}>{$tr->link('Tags', '/tags')}</li>
		{if $module_modify eq '1'}
			<li {if $method eq 'view'}class="on"{/if}>{$tr->link('New Tag', '/tags/view')}</li>
		{/if}
									
	</ul>


<div id="handlerChangeAlert"></div>

</div>


