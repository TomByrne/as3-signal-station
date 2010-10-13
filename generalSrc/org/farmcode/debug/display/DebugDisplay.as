package org.farmcode.debug.display
{
	import flash.geom.Point;
	
	import org.farmcode.collections.linkedList.LinkedList;
	import org.farmcode.core.IApplication;
	import org.farmcode.data.core.StringData;
	import org.farmcode.debug.data.core.DebugData;
	import org.farmcode.debug.nodeTypes.IDebugDataNode;
	import org.farmcode.debug.nodeTypes.IDebugNode;
	import org.farmcode.debug.nodeTypes.IGraphStatisticNode;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.containers.CascadingMenuBar;
	import org.farmcode.formatters.patternFormatters.PatternFormatter;
	import org.farmcode.instanceFactory.MultiInstanceFactory;
	
	use namespace DisplayNamespace;
	
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
				invalidatePos();
				invalidateSize();
			}
		}
		
		private var _application:IApplication;
		private var _menuItems:LinkedList;
		private var _graphSummaryData:DebugData;
		private var _graphData:DebugData;
		private var _graphLabel:PatternFormatter;
		private var _graphLabelPattern:StringData;
		private var _graphItems:Array = [];
		private var _graph:DebugGraph;
		
		public function DebugDisplay(asset:IDisplayAsset=null, application:IApplication=null){
			super(asset);
			this.application = application;
		}
		
		override protected function init() : void{
			super.init();
			
			var factory:MultiInstanceFactory = new MultiInstanceFactory(DebugItemRenderer);
			factory.useChildFactories = true;
			this.rendererFactory = factory;
			
			_graph = new DebugGraph(200,200);
			
			_menuItems = new LinkedList();
			_graphLabel = new PatternFormatter(_graphLabelPattern = new StringData());
			_graphLabel.quickValidate = true;
			_graphSummaryData = new DebugData(_graphLabel);
			_menuItems.push(_graphSummaryData);
			
			_graphData = new DebugData();
			_graphSummaryData.addChildData(_graphData);
			
			dataProvider = _menuItems;
			
			assessGraphLabel();
			
			this.gap = 2
			_layout.marginTop = 2;
			_layout.marginLeft = 2;
			_layout.marginRight = 2;
			_layout.marginBottom = 2;
		}
		public function addDebugNode(descendant:IDebugNode):void{
			attemptInit();
			var graphNode:IGraphStatisticNode = (descendant as IGraphStatisticNode);
			if(graphNode){
				_graph.addStatistic(graphNode.statisticProvider, graphNode.maximumProvider,graphNode.colour,graphNode.name);
				_graphItems.push(descendant);
				assessGraphLabel();
				_graphSummaryData.addChildData(new DebugData(graphNode.labelProvider));
			}
			var dataNode:IDebugDataNode = (descendant as IDebugDataNode);
			if(dataNode){
				_menuItems.push(dataNode.debugData);
			}
		}
		public function removeDebugNode(descendant:IDebugNode):void{
			if(descendant is IGraphStatisticNode){
				// remove from graph
				// remove from legend
				
				var index:int = _graphItems.indexOf(descendant);
				_graphItems.splice(index,1);
				assessGraphLabel();
			}
			var dataNode:IDebugDataNode = (descendant as IDebugDataNode);
			if(dataNode){
				_menuItems.removeFirst(dataNode.debugData);
			}
		}
		protected function assessGraphLabel() : void{
			_graphLabel.removeAllTokens();
			var labelPattern:String;
			var found:Boolean;
			for(var i:int=0; i<_graphItems.length; i++){
				var item:IGraphStatisticNode = _graphItems[i];
				if(item.summaryProvider){
					if(found){
						labelPattern += " ";
					}else{
						labelPattern = "";
						found = true;
					}
					var token:String = "${"+i+"}";
					labelPattern += token;
					_graphLabel.addToken(token,item.summaryProvider);
				}
			}
			if(!found){
				labelPattern = "Graph";
			}
			_graphLabelPattern.stringValue = labelPattern;
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(_application)_application.container = _containerAsset;
			
			CONFIG::debug{
				_graph.asset = _containerAsset.takeAssetByName(AssetNames.DEBUG_GRAPH_DISPLAY,IContainerAsset);
			}
			_containerAsset.removeAsset(_graph.asset);
			_graphData.layoutView = _graph;
		}
		override protected function unbindFromAsset() : void{
			var graphAsset:IDisplayAsset = _graph.asset;
			_graphData.layoutView = null;
			_graph.asset = null;
			_containerAsset.addAsset(graphAsset);
			_containerAsset.returnAsset(graphAsset);
			
			if(_application)_application.container = null;
			super.unbindFromAsset();
		}
		override protected function measure() : void{
			super.measure();
			invalidatePos();
			invalidateSize();
		}
		override protected function validatePosition():void{
			var pos:Point = position;
			var meas:Point = measurements;
			if(_application){
				_application.setPosition(pos.x,pos.y+meas.y);
			}
		}
		override protected function validateSize() : void{
			var size:Point = size;
			var meas:Point = measurements;
			drawListAndScrollbar(size.x,meas.y);
			positionBacking(size.x,meas.y);
			if(_application){
				_application.setSize(size.x,size.y-meas.y);
			}
		}
	}
}