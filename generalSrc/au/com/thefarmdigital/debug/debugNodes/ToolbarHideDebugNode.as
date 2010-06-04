package au.com.thefarmdigital.debug.debugNodes
{
	import au.com.thefarmdigital.display.controls.CustomButton;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.geom.Point;

	public class ToolbarHideDebugNode extends AbstractVisualDebugNode
	{
		private static const SELECTED_COLOUR:Number = 0xbb5599;
		private static const UNSELECTED_COLOUR:Number = 0x55bb99;
		private static const BUTTON_RADIUS:Number = 8;
		
		override public function set selected(value:Boolean): void{
			if(super.selected != value){
				super.selected = value;
				setSelected(value);
			}
		}
		
		private var toggleButton:CustomButton
		
		public function ToolbarHideDebugNode(){
			super();
			toggleButton = new CustomButton();
			toggleButton.selectedUpState = createState(SELECTED_COLOUR);
			toggleButton.upState = createState(UNSELECTED_COLOUR);
			toggleButton.addEventListener(MouseEvent.CLICK, onToggleClick);
			addChild(toggleButton);
			width = toggleButton.width = BUTTON_RADIUS*2;
			height = toggleButton.height = BUTTON_RADIUS*2;
		}
		protected function createState(colour:Number):DisplayObject{
			var ret:Shape = new Shape();
			ret.graphics.beginFill(colour);
			ret.graphics.drawCircle(BUTTON_RADIUS,BUTTON_RADIUS,BUTTON_RADIUS);
			ret.filters = [new BevelFilter()];
			return ret;
		}
		protected function onToggleClick(e:MouseEvent):void{
			setSelected(false);
		}
		protected function setSelected(selected:Boolean):void{
			toggleButton.selected = selected;
			parentToolbar.display.visible = (!selected);
			if(!selected){
				toggleButton.x = toggleButton.y = 0;
				addChild(toggleButton);
			}else{
				var point:Point = parentToolbar.display.parent.globalToLocal(localToGlobal(new Point()));
				toggleButton.x = point.x
				toggleButton.y = point.y;
				parentToolbar.display.parent.addChild(toggleButton);
			}
		}
	}
}