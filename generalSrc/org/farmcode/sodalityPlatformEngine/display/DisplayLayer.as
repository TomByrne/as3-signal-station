package org.farmcode.sodalityPlatformEngine.display
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	public class DisplayLayer
	{
		[Property(toString="true",clonable="true")]
		public var children: Array;
		
		protected var _display: DisplayObjectContainer;
		
		public function DisplayLayer()
		{
			this.children = new Array();
		}
		
		public function build(container: DisplayObjectContainer, index: int = -1): void
		{
			if (index < 0)
			{
				container.addChild(this.display);
			}
			else
			{
				container.addChildAt(this.display, index);
			}
			if (this._display is DisplayObjectContainer)
			{
				var childContainer: DisplayObjectContainer = this._display as DisplayObjectContainer;
				// iterate in reverse order so that XML representations will have top layers first
				for (var i: int = this.children.length-1; i >=0 ; i--)
				{
					var child: DisplayLayer = this.children[i];
					child.build(childContainer);
				}
			}
		}
		[Property(toString="true",clonable="true")]
		public function set display(display: DisplayObjectContainer): void
		{
			if (this._display != display)
			{
				this._display = display;
			}
		}
		public function get display(): DisplayObjectContainer
		{
			if (this._display == null)
			{
				this._display = new Sprite();
			}
			return this._display;
		}
	}
}