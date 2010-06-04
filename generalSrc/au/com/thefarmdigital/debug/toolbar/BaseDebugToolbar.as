package au.com.thefarmdigital.debug.toolbar
{
	import au.com.thefarmdigital.debug.debugNodes.IDebugNode;
	import au.com.thefarmdigital.display.View;
	import au.com.thefarmdigital.display.views.NestedList;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.instanceFactory.MultiInstanceFactory;
	import org.farmcode.instanceFactory.SimpleInstanceFactory;

	public class BaseDebugToolbar extends View implements IDebugToolbar
	{
		private static const PADDING:Number = 3;
		
		public function get display(): DisplayObject{
			return this;
		}
		public function get dataProvider():Array{
			return _dataProvider;
		}
		public function set dataProvider(value:Array):void{
			if(_dataProvider!=value){
				_dataProvider = value;
				if(_nestedList){
					_nestedList.dataProvider = value;
				}
				if(_dataProvider){
					setParentToolbar(_dataProvider);
				}
			}
		}
		public function get doStageAlign():Boolean{
			return _doStageAlign;
		}
		public function set doStageAlign(value:Boolean):void{
			if(_doStageAlign!=value){
				_doStageAlign = value;
				if(_doStageAlign){
					if(stage){
						executeStageAlign();
					}else{
						this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					}
				}else{
					if(!stage){
						this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					}else{
						stage.removeEventListener(Event.RESIZE,executeStageAlign);
					}
				}
			}
		}
		
		private var _doStageAlign:Boolean = false;
		private var _dataProvider:Array;
		private var _nestedList:NestedList;
		
		public function BaseDebugToolbar(){
			super();
			doStageAlign = true;
		}
		
		protected function onAddedToStage(e:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RESIZE,executeStageAlign);
			executeStageAlign();
		}
		protected function executeStageAlign(e:Event=null):void{
			this.width = stage.stageWidth;
			this.height = _nestedList.measuredHeight;
			var offset:Point = parent.localToGlobal(new Point());
			this.x = -offset.x;
			this.y = -offset.y;
		}
		protected function setParentToolbar(dataProvider:Array):void{
			for each(var moduleDisplay:IDebugNode in dataProvider){
				moduleDisplay.parentToolbar = this;
				if(moduleDisplay.childNodes)setParentToolbar(moduleDisplay.childNodes);
			}
		}
		override protected function initialise(): void{
			super.initialise();
			
			_nestedList = new NestedList();
			_nestedList.direction = Direction.HORIZONTAL;
			_nestedList.anchor = Anchor.TOP_LEFT;
			_nestedList.dataProvider = _dataProvider;
			_nestedList.topPadding = _nestedList.bottomPadding = _nestedList.leftPadding = _nestedList.rightPadding = PADDING;
			_nestedList.allowAutoSize = true;
			_nestedList.childrenField = "childNodes";
			_nestedList.gap = PADDING;
			_nestedList.separatorFactory = new SimpleInstanceFactory(DebugVerticalSeperator);
			
			_nestedList.itemFactory = new MultiInstanceFactory(DebugItemRenderer);
			
			var backing:Shape = new Shape();
			backing.graphics.beginFill(0);
			backing.graphics.drawRect(0,0,10,10);
			_nestedList.backing = backing;
			
			var listFactory:MultiInstanceFactory = new MultiInstanceFactory(NestedList);
			var listProps:Dictionary = new Dictionary();
			listProps["separatorFactory"] = new SimpleInstanceFactory(DebugHorizontalSeperator);
			listProps["topPadding"] = listProps["bottomPadding"] = listProps["leftPadding"] = listProps["rightPadding"] = listProps["gap"] = PADDING;
			listFactory.itemCreatedAct.addHandler(onRendererCreate);
			listFactory.addProperties(listProps);
			
			_nestedList.listFactory = listFactory;
			
			addChild(_nestedList);
		}
		protected function onRendererCreate(from:MultiInstanceFactory, list:NestedList): void{
			var backing:Shape = new Shape();
			backing.graphics.beginFill(0);
			backing.graphics.drawRoundRect(0,0,DebugItemRenderer.CORNER_ROUNDING*3,DebugItemRenderer.CORNER_ROUNDING*3,DebugItemRenderer.CORNER_ROUNDING*2,DebugItemRenderer.CORNER_ROUNDING*2);
			backing.scale9Grid = new Rectangle(DebugItemRenderer.CORNER_ROUNDING,DebugItemRenderer.CORNER_ROUNDING,DebugItemRenderer.CORNER_ROUNDING,DebugItemRenderer.CORNER_ROUNDING);
			list.backing = backing;
		}
		override protected function draw(): void{
			super.draw();
			
			_nestedList.width = this.width;
			_nestedList.height = this.height;
		}
	}
}