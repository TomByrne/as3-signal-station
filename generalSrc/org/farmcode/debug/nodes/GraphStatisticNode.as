package org.farmcode.debug.nodes
{
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.debug.nodeTypes.IGraphStatisticNode;
	import org.farmcode.display.core.IScopedObject;

	public class GraphStatisticNode extends AbstractDebugNode implements IGraphStatisticNode
	{
		public function get statisticProvider():INumberProvider{
			return _statisticProvider;
		}
		public function set statisticProvider(value:INumberProvider):void{
			_statisticProvider = value;
		}
		
		public function get label():String{
			return _label;
		}
		public function set label(value:String):void{
			_label = value;
		}

		public function get colour():Number{
			return _colour;
		}
		public function set colour(value:Number):void{
			_colour = value;
		}
		
		public function get showInSummary():Boolean{
			return _showInSummary;
		}
		public function set showInSummary(value:Boolean):void{
			_showInSummary = value;
		}
		
		private var _showInSummary:Boolean;
		private var _colour:Number;
		private var _label:String;
		private var _statisticProvider:INumberProvider;
		
		public function GraphStatisticNode(scopedObject:IScopedObject, label:String, colour:Number, statisticProvider:INumberProvider, showInSummary:Boolean){
			this.label = label;
			this.colour = colour;
			this.statisticProvider = statisticProvider;
			this.showInSummary = showInSummary;
			super(scopedObject);
		}
	}
}