package org.tbyrne.display.controls.toolTip
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.ISprite;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.controls.TextLabel;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.math.Trigonometry;
	import org.tbyrne.validation.IErrorDetails;
	
	use namespace DisplayNamespace;
	
	public class ToolTipDisplay extends TextLabel implements IToolTipDisplay
	{
		DisplayNamespace static const ARROW_ASSET:String = "arrow";
		private static const ORIGIN:Point = new Point();
		
		
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			if(_anchor!=value){
				_anchor = value;
				_anchorState.selectByString(value);
			}
		}
		
		public function get tipType():String{
			return _tipType;
		}
		public function set tipType(value:String):void{
			if(_tipType!=value){
				_tipType = value;
				_tipTypeState.selectByString(value);
			}
		}
		
		public function get anchorView():ILayoutView{
			return _anchorView;
		}
		public function set anchorView(value:ILayoutView):void{
			if(_anchorView!=value){
				if(_anchorView){
					_anchorView.sizeChanged.removeHandler(onAnchorSizeChanged);
					_anchorView.assetChanged.removeHandler(onAnchorAssetChanged);
				}
				_anchorView = value;
				if(_anchorView){
					_anchorView.sizeChanged.addHandler(onAnchorSizeChanged);
					_anchorView.assetChanged.addHandler(onAnchorAssetChanged);
				}
				invalidateSize();
			}
		}
		
		private var _tipType:String;
		private var _tipTypeState:StateDef = new StateDef([ToolTipTypes.CONTEXTUAL_TIP,ToolTipTypes.DATA_ENTRY_ERROR,ToolTipTypes.DATA_ENTRY_TIP]);
		private var _anchorView:ILayoutView;
		private var _anchor:String;
		private var _anchorState:StateDef = new StateDef([Anchor.TOP,Anchor.TOP_LEFT,Anchor.TOP_RIGHT,Anchor.LEFT,Anchor.RIGHT,Anchor.BOTTOM,Anchor.BOTTOM_LEFT,Anchor.BOTTOM_RIGHT]);
		private var _arrow:IDisplayObject;
		
		// often the asset will be scaled down to avoid screwing up it's parent assets initial measurements
		private var _origScaleX:Number;
		private var _origScaleY:Number;
		
		public function ToolTipDisplay(asset:IDisplayObject=null){
			super(asset);
		}
		protected function onAnchorSizeChanged(from:ILayoutView, oldWidth:Number, oldHeight:Number) : void{
			invalidateSize();
		}
		protected function onAnchorAssetChanged(from:ILayoutView, oldAsset:IDisplayObject) : void{
			invalidateSize();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_arrow = _containerAsset.takeAssetByName(ARROW_ASSET,IDisplayObject,true);
			//if(_arrow)_arrow.forceTopLeft = false;
			
			_spriteAsset.mouseChildren = false;
			_spriteAsset.mouseEnabled = false;
			
			_origScaleX = asset.scaleX;
			_origScaleY = asset.scaleY;
			asset.scaleX = 1;
			asset.scaleY = 1;
		}
		override protected function unbindFromAsset() : void{
			asset.scaleX = _origScaleX;
			asset.scaleY = _origScaleY;
			if(_arrow){
				_containerAsset.returnAsset(_arrow);
				_arrow = null;
			}
			super.unbindFromAsset();
		}
		override protected function measure() : void{
			super.measure();
		}
		override protected function commitSize():void{
			super.commitSize();
			if(_anchorView && _anchorView.asset){
				var anchorPos:Point = _anchorView.asset.localToGlobal(ORIGIN);
				anchorPos = anchorPos.subtract(_asset.localToGlobal(ORIGIN));
				
				var anchorSize:Point = _anchorView.size;
				
				var ancLeft:Number = anchorPos.x;
				var ancRight:Number = anchorPos.x+anchorSize.x;
				var ancTop:Number = anchorPos.y;
				var ancBottom:Number = anchorPos.y+anchorSize.y;
				
				var center:Point = new Point(size.x/2,size.y/2);
				
				var anchorSide:String;
				var intersect:Point;
				
				switch(_anchor){
					case Anchor.RIGHT:
						anchorPos.x += anchorSize.x;
						anchorSide = _anchor;
						break;
					case Anchor.LEFT:
						anchorSide = _anchor;
						break;
					default:
						anchorPos.x += anchorSize.x/2;
				}
				switch(_anchor){
					case Anchor.TOP:
						anchorPos.y += anchorSize.y;
						anchorSide = _anchor;
						break;
					case Anchor.BOTTOM:
						anchorSide = _anchor;
						break;
					default:
						anchorPos.y += anchorSize.y/2;
				}
				
				if(!anchorSide){
					var angle:Number = Trigonometry.getAngleTo(anchorPos,center);
					// ancCornerAngle is the angle from the centre of the anchorView to it's top-right corner, used to work out the side which the connector hits
					var ancCornerAngle:Number = Trigonometry.getAngleTo(ORIGIN,new Point(anchorSize.x/2,-anchorSize.y/2));
					if(angle<ancCornerAngle || angle>360-ancCornerAngle){
						anchorSide = Anchor.TOP;
					}else if(angle<180-ancCornerAngle){
						anchorSide = Anchor.RIGHT;
					}else if(angle<180+ancCornerAngle){
						anchorSide = Anchor.BOTTOM;
					}else if(angle<360-ancCornerAngle){
						anchorSide = Anchor.LEFT;
					}
				}
				switch(anchorSide){
					case Anchor.TOP:
						intersect = getIntersect(center,anchorPos,ancLeft,ancTop,ancRight,ancTop);
						break;
					case Anchor.RIGHT:
						intersect = getIntersect(center,anchorPos,ancRight,ancTop,ancRight,ancBottom);
						break;
					case Anchor.BOTTOM:
						intersect = getIntersect(center,anchorPos,ancRight,ancBottom,ancLeft,ancBottom);
						break;
					case Anchor.LEFT:
						intersect = getIntersect(center,anchorPos,ancLeft,ancBottom,ancLeft,ancTop);
						break;
				}
				setConnectionPoint(intersect, anchorSide);
			}else{
				setConnectionPoint(null,null);
			}
		}
		protected function setConnectionPoint(connection:Point, side:String):void {
			if(_arrow){
				if(connection){
					_arrow.setPosition(connection.x,connection.y);
					_arrow.visible = true;
				}else{
					_arrow.visible = false;
				}
			}
		}
		protected function getIntersect(line1Start:Point, line1End:Point, line2StartX:Number, line2StartY:Number, line2EndX:Number, line2EndY:Number):Point {
			var x1:Number = line1Start.x, x2:Number = line1End.x;
			var y1:Number = line1Start.y, y2:Number = line1End.y;
			var z1:Number= (x1 -x2), z2:Number = (line2StartX - line2EndX), z3:Number = (y1 - y2), z4:Number = (line2StartY - line2EndY);
			var d:Number = z1 * z4 - z3 * z2;
			
			// If d is zero, there is no intersection
			if (d == 0) return null;
			
			// Get the x and y
			var pre:Number = (x1*y2 - y1*x2), post:Number = (line2StartX*line2EndY - line2StartY*line2EndX);
			var x:Number = ( pre * z2 - z1 * post ) / d;
			var y:Number = ( pre * z4 - z3 * post ) / d;
			
			// Return the point of intersection
			return new Point(x, y);
			
			/*var ip:Point;
			var a1:Number;
			var a2:Number;
			var b1:Number;
			var b2:Number;
			var c1:Number;
			var c2:Number;
			
			a1= line1End.y-line1Start.y;
			b1= line1Start.x-line1End.x;
			c1= line1End.x*line1Start.y - line1Start.x*line1End.y;
			a2= line2EndY-line2StartY;
			b2= line2StartX-line2EndX;
			c2= line2EndX*line2StartY - line2StartX*line2EndY;
			
			var denom:Number=a1*b2 - a2*b1;
			if (denom == 0) {
				return null;
			}
			return new Point((b1*c2 - b2*c1)/denom, (a2*c1 - a1*c2)/denom);*/
		}
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_anchorState);
			fill.push(_tipTypeState);
			return fill;
		}
		override protected function syncFieldToData():void{
			if(data is Array){
				var errorText:String = "";
				for(var i:int=0; i<data.length; ++i){
					var error:IErrorDetails = data[i];
					if(error){
						if(errorText.length)errorText += "\n";
						errorText += error.message;
					}
				}
				if(errorText.length){
					if(_labelField.htmlText != errorText){
						_labelField.htmlText = errorText;
						invalidateMeasurements();
					}
					return;
				}
			}
			
			super.syncFieldToData();
		}
	}
}