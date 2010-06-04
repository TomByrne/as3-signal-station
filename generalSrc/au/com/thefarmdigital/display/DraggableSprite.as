package au.com.thefarmdigital.display
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	// TODO: Add rotation support
	/**
	 * The DraggableSprite class adds mouse dragging behaviour to the Sprite class.
	 */
	public class DraggableSprite extends Sprite
	{
		/**
		 * Whether drag is currently enabled on the sprite
		 */
		public function get dragEnabled(): Boolean
		{
			return this._dragEnabled;
		}
		/**
		 * @private
		 */
		public function set dragEnabled(dragEnabled: Boolean): void
		{
			if (dragEnabled != this._dragEnabled)
			{
				this._dragEnabled = dragEnabled;
				if (this._dragEnabled)
				{
					this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
				}
				else
				{
					this.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
					if (this.stage != null)
					{
						this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
						this.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
					}
				}
			}
		}
		
		private var dragOffset:Point;
		private var _dragEnabled: Boolean;
		
		/**
		 * Creates a new draggable sprite
		 */
		public function DraggableSprite(){
			this._dragEnabled = false;
			this.dragEnabled = true;
		}
		private function mouseDown(e:MouseEvent):void{
			dragOffset = new Point(mouseX,mouseY);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseUp);
		}
		private function mouseUp(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
		}
		private function mouseMove(e:MouseEvent):void{
			var mouseDistance:Point = getMouseDistance();
			x += mouseDistance.x;
			y += mouseDistance.y;
		}
		
		/**
		 * Find the distance of the mouse away from the last mouse down location
		 * 
		 * @return	The distance from the mouse down as a point
		 */
		private function getMouseDistance():Point
		{
			var bounds:Rectangle = this.getBounds(parent);
			var oldMousePoint:Point = new Point(bounds.x+dragOffset.x,bounds.y+dragOffset.y);
			return new Point(parent.mouseX-oldMousePoint.x,parent.mouseY-oldMousePoint.y);
		}
	}
}