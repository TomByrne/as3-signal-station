package org.tbyrne.debug.nodes
{
	import org.tbyrne.data.core.NumberData;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.debug.data.core.HexNumberData;
	import org.tbyrne.debug.data.core.MaximumNumber;
	import org.tbyrne.debug.data.core.NumberRounder;
	import org.tbyrne.debug.nodeTypes.IGraphStatisticNode;
	import org.tbyrne.display.core.IScopedObject;
	import org.tbyrne.formatters.patternFormatters.PatternFormatter;

	public class GraphStatisticNode extends AbstractDebugNode implements IGraphStatisticNode
	{
		private static const COLOUR_TOKEN:String = "${colour}";
		private static const LABEL_TOKEN:String = "${label}";
		private static const VALUE_TOKEN:String = "${value}";
		private static const MAX_TOKEN:String = "${max}";
		
		public function get statisticProvider():INumberProvider{
			return _statisticProvider;
		}
		public function set statisticProvider(value:INumberProvider):void{
			_statisticProvider = value;
			_assumedValueRounder.numberProvider = value;
		}
		public function get maximumProvider():INumberProvider{
			return _maximumProvider || _assumedMaxProvider;
		}
		public function set maximumProvider(value:INumberProvider):void{
			_maximumProvider = value;
			if(value==null)_assumedLabelProvider.addToken(MAX_TOKEN,_assumedMaxProvider);
			else _assumedLabelProvider.addToken(MAX_TOKEN,_maximumProvider);
		}
		
		public function set showInSummary(value:Boolean):void{
			_showInSummary = value;
		}
		public function get summaryProvider():IStringProvider{
			if(_summaryProvider)return _summaryProvider;
			else if(_showInSummary)return _assumedLabelProvider;
			else return null;
		}
		public function set summaryProvider(value:IStringProvider):void{
			_summaryProvider = value;
		}
		
		public function get name():String{
			return _name;
		}
		public function set name(value:String):void{
			_name = value;
			if(value==null)_assumedLabelProvider.removeToken(LABEL_TOKEN);
			else _assumedLabelProvider.addToken(LABEL_TOKEN,new StringData(value));
		}
		public function get labelProvider():IStringProvider{
			return _labelProvider || _assumedLabelProvider;
		}
		public function set labelProvider(value:IStringProvider):void{
			_labelProvider = value;
		}

		public function get colour():Number{
			return _colour;
		}
		public function set colour(value:Number):void{
			_colour = value;
			if(isNaN(colour))_assumedLabelProvider.removeToken(COLOUR_TOKEN);
			else _assumedLabelProvider.addToken(COLOUR_TOKEN,new HexNumberData(colour));
		}
		
		private var _showInSummary:Boolean;
		private var _colour:Number;
		private var _name:String;
		private var _labelProvider:IStringProvider;
		private var _summaryProvider:IStringProvider;
		
		private var _statisticProvider:INumberProvider;
		private var _maximumProvider:INumberProvider;
		
		private var _assumedLabelProvider:PatternFormatter;
		private var _assumedMaxProvider:MaximumNumber;
		private var _assumedValueRounder:NumberRounder;
		
		public function GraphStatisticNode(scopedObject:IScopedObject, name:String, colour:Number, statisticProvider:INumberProvider, showInSummary:Boolean){
			_assumedLabelProvider = new PatternFormatter(new StringData(LABEL_TOKEN+": <font color='#"+COLOUR_TOKEN+"'>"+VALUE_TOKEN+"/"+MAX_TOKEN+"</font>"));
			_assumedLabelProvider.quickValidate = true;
			_assumedValueRounder = new NumberRounder();
			_assumedMaxProvider = new MaximumNumber(_assumedValueRounder);
			_assumedLabelProvider.addToken(MAX_TOKEN,_assumedMaxProvider);
			_assumedLabelProvider.addToken(VALUE_TOKEN,_assumedValueRounder);
			
			this.showInSummary = showInSummary;
			this.name = name;
			this.colour = colour;
			this.statisticProvider = statisticProvider;
			super(scopedObject);
		}
	}
}