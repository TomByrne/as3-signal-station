package org.farmcode.debug.display
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.linkedList.LinkedList;
	import org.farmcode.core.IApplication;
	import org.farmcode.data.core.StringData;
	import org.farmcode.debug.data.core.DebugData;
	import org.farmcode.debug.nodeTypes.IDebugNode;
	import org.farmcode.debug.nodeTypes.IGraphStatisticNode;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.containers.CascadingMenuBar;
	import org.farmcode.formatters.patternFormatters.PatternFormatter;
	import org.farmcode.instanceFactory.MultiInstanceFactory;
	
	public class DebugDisplay extends CascadingMenuBar
	{
		
		public function get application():IApplication{
			return _application;
		}
		public function set application(value:IApplication):void{
			if(_application!=value){
				if(_asset && _application)_application.container = null;
				_application = value;
				if(_asset && _application)_application.container = _containerAsset;
				invalidate();
			}
		}
		
		private var _application:IApplication;
		private var _menuItems:LinkedList;
		private var _graphLabel:PatternFormatter;
		private var _graphLabelPattern:StringData;
		private var _graphItems:Array = [];
		
		public function DebugDisplay(asset:IDisplayAsset=null, application:IApplication=null){
			super(asset);
			this.application = application;
		}
		
		override protected function init() : void{
			super.init();
			
			this.rendererFactory = new MultiInstanceFactory(DebugItemRenderer);
			
			_menuItems = new LinkedList();
			_graphLabel = new PatternFormatter(_graphLabelPattern = new StringData());
			_graphLabel.quickValidate = true;
			var graphData:DebugData = new DebugData(_graphLabel);
			_menuItems.push(graphData);
			
			var graph:DebugData = new DebugData(new StringData("Graph"),new BitmapData(200,200,false,0xff0000));
			graphData.addChildData(graph);
			
			dataProvider = _menuItems;
			
			
			
			measurementsChanged.addHandler(onMeasChanged);
			
			assetGraphLabel();
			
			this.gap = 2
			_layout.marginTop = 2;
			_layout.marginLeft = 2;
			_layout.marginRight = 2;
			_layout.marginBottom = 2;
		}
		public function addDebugNode(descendant:IDebugNode):void{
			if(descendant is IGraphStatisticNode){
				_graphItems.push(descendant);
				assetGraphLabel();
			}
		}
		public function removeDebugNode(descendant:IDebugNode):void{
			if(descendant is IGraphStatisticNode){
				var index:int = _graphItems.indexOf(descendant);
				_graphItems.splice(index,1);
				assetGraphLabel();
			}
		}
		protected function assetGraphLabel() : void{
			_graphLabel.removeAllTokens();
			var labelPattern:String;
			var found:Boolean;
			for each(var item:IGraphStatisticNode in _graphItems){
				if(item.showInSummary){
					if(found){
						labelPattern += " ";
					}else{
						labelPattern = "";
						found = true;
					}
					var token:String = "${"+item.label+"}";
					labelPattern += item.label+": <font color='#"+item.colour.toString(16)+"'>"+token+"</font>";
					_graphLabel.addToken(token,item.statisticProvider);
				}
			}
			if(!found){
				labelPattern = "Graph";
			}
			_graphLabelPattern.stringValue = labelPattern;
		}
		protected function onMeasChanged(from:DebugDisplay, oldWidth:Number, oldHeight:Number) : void{
			invalidate();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(_application)_application.container = _containerAsset;
		}
		override protected function unbindFromAsset() : void{
			if(_application)_application.container = null;
			super.unbindFromAsset();
		}
		override protected function measure() : void{
			super.measure();
		}
		override protected function draw() : void{
			positionAsset();
			var pos:Rectangle = displayPosition;
			var meas:Point = measurements;
			drawListAndScrollbar(0,0,pos.width,meas.y);
			positionBacking(0,0,pos.width,meas.y);
			if(_application){
				_application.setDisplayPosition(pos.x,pos.y+meas.y,pos.width,pos.height-meas.y);
			}
		}
	}
}