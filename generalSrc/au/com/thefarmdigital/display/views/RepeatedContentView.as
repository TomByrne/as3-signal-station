package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.View;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.reflection.ReflectionUtils;

	public class RepeatedContentView extends View
	{
		protected var _anchor: String;
		protected var _contentClass: Class;
		private var tileTypeValid: Boolean;
		private var tileHolder: DisplayObjectContainer;
		private var _gap: Number;
		
		public function RepeatedContentView()
		{
			super();
			
			// TODO: Possibly a dyunamic anchor center depending on where current items are.
			// e.g. 20% : 80%
			var defaultBounds: Rectangle = this.getBounds(this);
			if (defaultBounds.x == 0 && defaultBounds.width > 0)
			{
				this._anchor = Anchor.LEFT;
			}
			else if (defaultBounds.width != 0 && (defaultBounds.x + defaultBounds.width) == 0)
			{
				this._anchor = Anchor.RIGHT;
			}
			else
			{
				this._anchor = Anchor.CENTER;
			}
			
			this.tileTypeValid = true;
			
			this._gap = 0;
			if (this.numChildren > 0)
			{
				var firstChild: DisplayObject = this.getChildAt(0);
				if (firstChild.width > 0)
				{
					this._contentClass = ReflectionUtils.getClass(firstChild);
				}
				
				if (this.numChildren > 1)
				{
					var children: Array = new Array(this.numChildren);
					for (var i: uint = 0; i < this.numChildren; ++i)
					{
						var child: DisplayObject = this.getChildAt(i);
						children[i] = child;
					}
					children.sortOn("x");
					var child1: DisplayObject = children[0];
					var child2: DisplayObject = children[1];
					var bounds1: Rectangle = child1.getBounds(this);
					var bounds2: Rectangle = child2.getBounds(this);
					this._gap = bounds2.x - bounds1.x - bounds1.width;
				}
			}
			
			while (this.numChildren > 0)
			{
				var remChild: DisplayObject = this.getChildAt(0);
				this.removeChild(remChild);
			}
			
			this.tileHolder = new Sprite();
			this.addChild(this.tileHolder);
		}
		
		public function set gap(gap: Number): void
		{
			this._gap = gap;
			this.invalidateTileType();
		}
		
		public function set anchor(anchor: String): void
		{
			this._anchor = anchor;
			this.invalidateTileType();
		}
		
		public function set contentClass(contentClass: Class): void
		{
			this._contentClass = contentClass;
			this.invalidateTileType();
		}
		
		private function invalidateTileType(): void
		{
			this.tileTypeValid = false;
			this.invalidate();
		}
		
		override protected function draw(): void
		{
			if (!this.tileTypeValid)
			{
				this.trimTiles();
				this.tileTypeValid = true;
			}
			
			switch (this._anchor)
			{
				case	Anchor.CENTER:
					this.drawAnchorCenter();
					break;
				case	Anchor.LEFT:
					this.drawAnchorLeft();
					break;
				case	Anchor.RIGHT:
					this.drawAnchorRight();
					break;
			}
		}
		
		protected function drawAnchorRight(): void
		{
			this.tileHolder.x = 0;
			
			while (this.tileHolder.width + this._gap < this.width)
			{
				var newTile: DisplayObject = this.getOrCreateTile();
				if (this.tileHolder.numChildren > 0)
				{
					var bounds: Rectangle = this.tileHolder.getBounds(this.tileHolder);
					newTile.x = Math.round(bounds.x - this._gap - newTile.width);
				}
				else
				{
					newTile.x = -Math.round(newTile.width);
				}
				this.tileHolder.addChildAt(newTile, 0);
			}
			
			/*var moreToRemove: Boolean = true;
			while (moreToRemove && this.tileHolder.numChildren > 0)
			{
				var leftTile: DisplayObject = this.tileHolder.getChildAt(0);
				if (leftTile.x + leftTile.width < this.width)
				{
					this.tileHolder.removeChild(leftTile);
				}
				else
				{
					moreToRemove = false;
				}
			}*/
		}
		
		// TODO: Refactor these funcitons
		protected function drawAnchorLeft(): void
		{
			this.tileHolder.x = 0;
			
			while (this.tileHolder.width + this._gap < this.width)
			{
				var newTile: DisplayObject = this.getOrCreateTile();
				if (this.tileHolder.numChildren > 0)
				{
					newTile.x = this.tileHolder.width + this._gap;
				}
				else
				{
					newTile.x = 0;
				}
				this.tileHolder.addChild(newTile);
			}
			
			var moreToRemove: Boolean = true;
			while (moreToRemove && this.tileHolder.numChildren > 0)
			{
				var rightTile: DisplayObject = this.tileHolder.getChildAt(this.tileHolder.numChildren - 1);
				if (rightTile.x > this.width)
				{
					this.tileHolder.removeChild(rightTile);
				}
				else
				{
					moreToRemove = false;
				}
			}
		}
		
		protected function getOrCreateTile(): DisplayObject
		{
			// TODO: Cache these?
			return new this._contentClass();
		}
		
		protected function drawAnchorCenter(): void
		{
			var HALF_WIDTH: uint = this.width / 2;
			this.tileHolder.x = this.width / 2;
			
			var bounds: Rectangle = null;
			// Add tiles to left
			var addMoreLeft: Boolean = true;
			while (addMoreLeft)
			{
				bounds = this.tileHolder.getBounds(this.tileHolder);
				if (bounds.x > -HALF_WIDTH)
				{
					var leftTile: DisplayObject = this.getOrCreateTile();
					var leftTileBounds: Rectangle = leftTile.getBounds(leftTile);
					leftTile.x = bounds.x - leftTileBounds.x - leftTileBounds.width - this._gap;
					this.tileHolder.addChildAt(leftTile, 0);
				}
				else
				{
					addMoreLeft = false;
				}
			}
			// Add tiles to right
			var addMoreRight: Boolean = true;
			while (addMoreRight)
			{
				bounds = this.tileHolder.getBounds(this.tileHolder);
				if ((bounds.x + bounds.width) < HALF_WIDTH)
				{
					var rightTile: DisplayObject = this.getOrCreateTile();
					var rightTileBounds: Rectangle = rightTile.getBounds(rightTile);
					rightTile.x = bounds.x - rightTileBounds.x + bounds.width + this._gap;
					this.tileHolder.addChild(rightTile);
				}
				else
				{
					addMoreRight = false;
				}
			}
			
			// Remove excess tiles to right
			var moreRightToRemove: Boolean = true;
			while (moreRightToRemove && (this.tileHolder.numChildren > 0))
			{
				var nextRight: DisplayObject = this.tileHolder.getChildAt(this.tileHolder.numChildren - 1);
				if (nextRight.x > HALF_WIDTH)
				{
					this.tileHolder.removeChild(nextRight);
				}
				else
				{
					moreRightToRemove = false;
				}
			}
			
			// Remove excess tiles to left
			var moreLeftToRemove: Boolean = true;
			while (moreLeftToRemove && (this.tileHolder.numChildren > 0))
			{
				var nextLeft: DisplayObject = this.tileHolder.getChildAt(0);
				if ((nextLeft.x + nextLeft.width) < -HALF_WIDTH)
				{
					this.tileHolder.removeChild(nextLeft);
				}
				else
				{
					moreLeftToRemove = false;
				}
			}
		}
		
		protected function trimTiles(): void
		{
			while (this.tileHolder.numChildren > 0)
			{
				var child: DisplayObject = this.tileHolder.getChildAt(0);
				this.tileHolder.removeChild(child);
			}
		}
	}
}