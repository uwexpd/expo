var time_range = 0;

function updateChart(chart_data)
{
	//alert(request.responseText );
	$("swf-chart-replacement").load( chart_data );
}

function open_flash_chart_data()
{
	buildChartAjaxQuery();
	var temp = '{ "elements": [ { "type": "bar", "values": [0,0,0,0,0,0,0]}],"title": { "text": "Loading Chart...", "style": "{font-size: 10px; color: #dadada;}" },"y_axis":{"colour":"#909090","min":0,"grid-colour":"#9ABADB"},"x_axis":{"colour":"#909090","grid-colour":"#9ABADB"},"bg_colour":"#FFFFFF"}';
	return temp;
}
 

function processAppointmentChartResult(request)
{
	var data = request.responseText.split("|SPLIT|");
	if (data.length == 1)
	{
		updateChart(data[0]);
	}
	else
	{
		updateChart(data[1]);
		var stats = data[0].evalJSON();
		var form = $('graph_form');
		changeStatSpans($$('.radio-project-number'), $$('.radio-project-percent'), form.getInputs('radio', 'p'), stats.p);
		changeStatSpans($$('.radio-standing-number'), $$('.radio-standing-percent'), form.getInputs('radio', 'c'), stats.c);
		changeStatSpans($$('.radio-gender-number'), $$('.radio-gender-percent'), form.getInputs('radio', 'g'), stats.g);
		//alert(percents.p[0]);
	}
}

function changeStatSpans(count_spans, percent_spans, buttons, stats)
{
	var total = stats[0]
	for ( i = 0; i < buttons.length; i++ )
	{
		//alert(buttons[i].value+" "+percents.p[buttons[i].value]);
		if (stats[buttons[i].value] != null)
		{
			count_spans[i].innerHTML = " "+stats[buttons[i].value]+" ";
			percent_spans[i].innerHTML = " "+Math.round((stats[buttons[i].value] * 100) / total)+"%";
			new Effect.Highlight(count_spans[i], { startcolor: '#ffff99', endcolor: '#ffffff' });
			new Effect.Highlight(percent_spans[i], { startcolor: '#ffff99', endcolor: '#ffffff' });
		}
		else
		{
			count_spans[i].innerHTML = " 0 ";
			percent_spans[i].innerHTML = " 0% ";
		}
	}
}

function buildChartAjaxQuery(passed_time_range)
{
	if (passed_time_range != null)
	{
		time_range = passed_time_range;
	}
	
	query_string = gatherValues("graph_form");
	if (query_string == null)
	{
		return;
	}
	//alert(time_range+' & '+query_string);
	try 
	{ 
		Element.show('indicator')
	} 
	catch(e) 
	{ 
		alert('The remote helper indicator \'indicator\' has not been defined.')
	}; 
	new Ajax.Request
	(
		base_url+time_range+'&'+query_string+'', 
		{
			asynchronous:true, evalScripts:true, onComplete:function(request)
			{
			Element.hide('indicator');
			processAppointmentChartResult(request)
			}
		}
	); 
	return false;
	
}

function gatherValues(form_name)
{
	
   var query_string = '';
   var current_field = null;
   for (var i=0; i < document.forms[form_name].elements.length; i++) 
   {
       var elt = document.forms[form_name].elements[i];
       // concatenate some stuff in here
	   
	   if (elt.checked == true) 
	   {
			if (current_field != elt.name)
			{
				if (current_field != null)
				{
					query_string += '&';
				}
				query_string += elt.name+'=';
				current_field = elt.name;
			}
			else
			{
				query_string += '+';
			}
			query_string += elt.value;
	   }
   }
   return query_string;
}

swfobject.embedSWF(root_url + "/open-flash-chart.swf", "swf-chart-replacement", "100%", "100%", "9.0.0", "expressInstall.swf");