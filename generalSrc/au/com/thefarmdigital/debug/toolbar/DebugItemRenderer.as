package au.com.thefarmdigital.debug.toolbar
{
	import au.com.thefarmdigital.debug.debugNodes.IDebugNode;
	import au.com.thefarmdigital.debug.events.DebugNodeEvent;
	import au.com.thefarmdigital.display.controls.Button;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class DebugItemRenderer extends Button
	{
		private static const NON_BUTTON_COLOUR:Number = 0x333333;
		private static const UP_COLOUR:Number = 0x555555;
		private static const OVER_COLOUR:Number = 0x888888;
		internal static const CORNER_ROUNDING:Number = 3.5;
		
		override public function set data(value:*) : void{
			if(_debugNode){
				_debugNode.removeEventListener(DebugNodeEvent.NODE_CHANGE, onNodeChange);
			}
			super.data = value;
			_debugNode = (value as IDebugNode);
			if(_debugNode){
				_debugNode.addEventListener(DebugNodeEvent.NODE_CHANGE, onNodeChange);
				_debugNode.selected = selected;
				onNodeChange();
			}
			invalidate();
		}
		public function get appearAsButton():Boolean{
			return _appearAsButton;
		}
		public function set appearAsButton(value:Boolean):void{
			if(_appearAsButton!=value){
				_appearAsButton = value;
				if(_appearAsButton){
					upState = createState(UP_COLOUR,CORNER_ROUNDING);
					overState = createState(OVER_COLOUR,CORNER_ROUNDING);
				}else{
					upState = overState = null;
				}
			}
		}
		override public function set selected(value:Boolean):void{
			super.selected = value;
			if(_debugNode)_debugNode.selected = value;
		}
		
		private var _appearAsButton:Boolean = true; // to trigger initial setting
		private var _debugNode:IDebugNode;
		
		public function DebugItemRenderer(){
			super();
			this.labelPlacement = TextFormatAlign.LEFT;
			labelField = new TextField();
			labelField.defaultTextFormat = new TextFormat("_sans",10,0xffffff);
			labelField.gridFitType = GridFitType.PIXEL;
			
			appearAsButton = false;
			
			labelPadding = new Rectangle(CORNER_ROUNDING,CORNER_ROUNDING,CORNER_ROUNDING,CORNER_ROUNDING);
		}
		protected function onNodeChange(e:Event=null) : void{
			label = _debugNode.label;
			icon = _debugNode.icon;
			labelField.textColor = _debugNode.labelColour;
			selectedUpState = new Shape();
			appearAsButton = _debugNode.appearAsButton;
		}
		protected function createState(colour:Number, cornerRounding:Number):DisplayObject{
			var state:Shape = new Shape();
			state.graphics.beginFill(colour);
			if(cornerRounding>0){
				state.graphics.drawRoundRect(0,0,cornerRounding*3,cornerRounding*3,cornerRounding*2,cornerRounding*2);
				state.scale9Grid = new Rectangle(cornerRounding,cornerRounding,cornerRounding,cornerRounding);
			}else{
				state.graphics.drawRect(0,0,10,10);
			}
			return state;
		}
	}
}