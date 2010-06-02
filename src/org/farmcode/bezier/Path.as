package org.farmcode.bezier
{
	import flash.display.Graphics;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.collections.IIterator;
	import org.farmcode.collections.linkedList.LinkedList;
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.hoborg.ISelfCloning;
	import org.farmcode.hoborg.ObjectPool;
	import org.farmcode.math.Trigonometry;
	
	public class Path extends EventDispatcher implements ISelfCloning
	{
		private static const bezierPool:ObjectPool = new ObjectPool(Bezier);
		
		public function get length():Number{
			validateShape();
			return _length;
		}
		public function get pointCount():uint{
			return _pointList.length;
		}
		[Property(toString="true",clonable="true")]
		public function get closed():Boolean{
			return _closed;
		}
		public function set closed(value:Boolean):void{
			if(value!=_closed){
				_closed = value;
				_invalidateShape();
			}
		}
		[Property(toString="true",clonable="true")]
		public function get autoFillVectors():Boolean{
			return _autoFillVectors;
		}
		public function set autoFillVectors(value:Boolean):void{
			if(value!=_autoFillVectors){
				_autoFillVectors = value;
				_invalidateShape();
			}
		}
		[Property(toString="true",clonable="true")]
		public function get autoFillTension():Number{
			return _autoFillTension;
		}
		public function set autoFillTension(value:Number):void{
			if(value!=_autoFillTension){
				_autoFillTension = value;
				_invalidateShape();
			}
		}
		[Property(toString="true",clonable="true")]
		public function get tolerance():Number{
			return _tolerance;
		}
		public function set tolerance(value:Number):void{
			if(value!=_tolerance){
				_tolerance = value;
				var iterator:IIterator = _bezierList.getIterator();
				var bezier:Bezier;
				while(bezier = iterator.next()){
					bezier.tolerance = value;
				}
				iterator.release();
			}
		}
		public function set points(value:Array):void{
			var iterator:IIterator = _pointList.getIterator();
			var point:BezierPoint;
			while(point = iterator.next()){
				point.positionChanged.removeHandler(onPointPosChange);
				point.angleDistanceChanged.removeHandler(onPointVectorChange);
			}
			iterator.release();
			
			iterator = _bezierList.getIterator();
			var bezier:Bezier;
			while(bezier = iterator.next()){
				bezierPool.releaseObject(bezier);
				if(bezier.start)bezier.start.release();
			}
			iterator.release();
			
			_pointList.reset();
			_bezierList.reset();
			
			if (value) {
				var length:int = value.length;
				for(var i:int=0; i<length; ++i){
					addPoint(value[i]);
				}
				_invalidateShape();
			}
		}
		
		/**
		 * handler(from:Path)
		 */
		public function get shapeChanged():IAct{
			if(!_shapeChanged)_shapeChanged = new Act();
			return _shapeChanged;
		}
		
		protected var _shapeChanged:Act;
		
		private var _autoFillVectors:Boolean = true;
		private var _autoFillTension:Number = 0;
		private var _tolerance:Number = 5;
		private var invalidShape:Boolean = true;
		private var _closed:Boolean = false;
		private var _length:Number;
		
		// these two are parallel
		private var _pointList:LinkedList = new LinkedList();
		private var _bezierList:LinkedList = new LinkedList();
		
		public function addPoint(point:BezierPoint):void{
			addPointAt(point, _pointList.length);
		}
		public function addPointAt(point:BezierPoint, index:Number):void{
			_pointList.splice(index,0,[point]);
			
			var bezier:Bezier = bezierPool.takeObject();
			bezier.tolerance = _tolerance;
			_bezierList.splice(index,0,[bezier]);
			
			point.positionChanged.addHandler(onPointPosChange);
			point.angleDistanceChanged.addHandler(onPointVectorChange);
			
			_invalidateShape();
		}
		public function getPointIterator():IIterator{
			return _pointList.getIterator();
		}
		public function getPoint(index:uint):BezierPoint{
			return _pointList.get(index);
		}
		public function removePoint(point:*):void{
			var bezPoint:BezierPoint;
			var index:int = -1;
			if(point is BezierPoint){
				bezPoint = point;
				index = _pointList.firstIndexOf(point);
			}else if(point is Number){
				index = point;
			}
			if(index>-1){
				if(!bezPoint)bezPoint = _pointList.get(index);
				bezPoint.positionChanged.removeHandler(onPointPosChange);
				bezPoint.angleDistanceChanged.removeHandler(onPointVectorChange);
				_pointList.splice(index,1);
				var bezier:Bezier = _bezierList.get(index);
				bezierPool.releaseObject(bezier);
				_bezierList.splice(index,1);
				
				_invalidateShape();
			}
		}
		public function getBezierAt(fract:Number, getVectors:Boolean):BezierPoint{
			if(fract<0 || fract>1)throw new Error("Path.getBezierAt: fract must be between 0 and 1");
			validateShape();
			var totalLength:Number = length;
			var bezier:Bezier;
			var localFract:Number = 0;
			if(totalLength){
				var stack:Number = 0;
				var iterator:IIterator = _bezierList.getIterator();
				var _bezier:Bezier;
				while(_bezier = iterator.next()){
					var len:Number = _bezier.length;
					if((stack+len)/totalLength>=fract){
						bezier = _bezier;
						localFract = ((fract*totalLength)-stack)/len;
						break;
					}
					stack += len;
				}
				iterator.release()
			}else{
				bezier = _bezierList.get(0);
			}
			var point:BezierPoint = (bezier?bezier.getPointAt(localFract,getVectors):null);
			return point;
		}
		public function getFractAt(index:uint):Number{
			var totalLength:Number = length;
			if(totalLength){
				var _length:Number = 0;
				var iterator:IIterator = _bezierList.getIterator();
				var _bezier:Bezier;
				var i:int=0;
				while(i<index && (_bezier = iterator.next())){
					_length += _bezier.length;
					i++
				}
				iterator.release()
				return _length/totalLength;
			}else{
				return 0;
			}
		}
		
		public function get height(): Number
		{
			var minY: Number = 0;
			var maxY: Number = 0;
			var iterator:IIterator = _pointList.getIterator();
			var point:BezierPoint;
			while(point = iterator.next()){
				minY = Math.min(minY, point.y);
				maxY = Math.max(maxY, point.y);
			}
			iterator.release()
			return maxY - minY;
		}
		
		public function get width(): Number
		{
			var minX: Number = 0;
			var maxX: Number = 0;
			var iterator:IIterator = _pointList.getIterator();
			var point:BezierPoint;
			while(point = iterator.next()){
				minX = Math.min(minX, point.x);
				maxX = Math.max(maxX, point.x);
			}
			iterator.release()
			return maxX - minX;
		}
		
		public function drawInto(graphics:Graphics, modifiers:Array=null):void{
			validateShape();
			var iterator:IIterator = _bezierList.getIterator();
			var bezier:Bezier;
			var first:Boolean = true;
			while(bezier = iterator.next()){
				bezier.drawInto(graphics, first, modifiers);
				first = false;
			}
			iterator.release()
		}
		protected function linkBeziers():void{
			if(_pointList.length){
				var bezIterator:IIterator = _bezierList.getIterator();
				var pointIterator:IIterator = _pointList.getIterator();
				var bezier:Bezier;
				var point:BezierPoint;
				var pointClone:BezierPoint;
				var old:BezierPoint;
				var lastBezier:Bezier;
				while((bezier = bezIterator.next()) && (point = pointIterator.next())){
					pointClone = point.clone();
					
					old = bezier.start;
					bezier.start = pointClone;
					if(old)old.release();
					if(lastBezier){
						lastBezier.end = pointClone;
					}
					lastBezier = bezier;
				}
				// connect the last bezier to the first point
				if(_closed)lastBezier.end = (_bezierList.get(0) as Bezier).start;
				
				bezIterator.release()
				pointIterator.release()
			}
		}
		protected function autoFill():void{
			if(autoFillVectors && _bezierList.length && _autoFillTension<1){
				var invTension:Number = Math.max(1-autoFillTension,0);
				if(!invTension)return;
				
				var bezIterator:IIterator = _bezierList.getIterator();
				var prevBezier:Bezier;
				var nextBezier:Bezier;
				
				var pointIterator:IIterator = _pointList.getIterator();
				var nextPoint:BezierPoint;
				
				var looped:Boolean;
				var i:int=0;
				while((nextBezier = bezIterator.next()) || (closed && !looped)){
					if(!nextBezier){
						looped = true;
						nextBezier = _bezierList.get(0);
						nextPoint = _pointList.get(0);
					}else{
						nextPoint = pointIterator.next();
					}
					if(prevBezier){
						var do1:Boolean = (prevBezier.start && prevBezier.end);
						var do2:Boolean = (nextBezier.start && nextBezier.end);
						
						var dist1:Number;
						var dist2:Number;
						var angle1:Number;
						var angle2:Number;
						if(do1){
							var staPoint:Point = prevBezier.start.toPoint();
							var endPoint:Point = prevBezier.end.toPoint();
							dist1 = Trigonometry.getDistance(endPoint,staPoint);
							angle1 = Trigonometry.getAngleTo(endPoint,staPoint);
						}
						if(do2){
							staPoint = nextBezier.start.toPoint();
							endPoint = nextBezier.end.toPoint();
							dist2 = Trigonometry.getDistance(staPoint,endPoint);
							angle2 = Trigonometry.getAngleTo(staPoint,endPoint);
							if(do1){
								var ratio:Number = 0.5;
								var angle:Number = (angle1*(1-ratio))+(angle2*ratio);
								var dir:Number = (angle1<angle2?-1:1);
							}
						}
						if(nextPoint.backwardVector){
							prevBezier.end.backwardVector = nextPoint.backwardVector;
						}else if(do1){
							if(do2){
								prevBezier.end.backwardAngle = angle+(90*dir);
							}else{
								prevBezier.end.backwardAngle = angle1;
							}
							prevBezier.end.backwardDistance = dist1*0.5*invTension;
						}
						if(nextPoint.forwardVector){
							nextBezier.start.forwardVector = nextPoint.forwardVector;
						}else if(do2){
							if(do1 && (_closed || i<_bezierList.length-1)){
								nextBezier.start.forwardAngle = angle-(90*dir);
							}else{
								nextBezier.start.forwardAngle = angle2;
							}
							nextBezier.start.forwardDistance = dist2*0.5*invTension;
						}
					}
					prevBezier = nextBezier;
					i++;
				}
				bezIterator.release()
			}
		}
		
		public function invalidateShape():void{
			_invalidateShape();
		}
		protected function _invalidateShape(... params):void{
			invalidShape = true;
			this.dispatchShapeChanged();
		}
		protected function onPointPosChange(from:BezierPoint, oldX:Number, oldY:Number, newX:Number, newY:Number):void{
			var index:int = _pointList.firstIndexOf(from);
			if(index!=-1){
				linkBeziers();
				var bezier:Bezier = _bezierList.get(index);
				bezier.start.x = newX;
				bezier.start.y = newY;
				this.dispatchShapeChanged();
			}
		}
		protected function onPointVectorChange(from:BezierPoint, oldBackAngle:Number, oldBackDist:Number, oldForAngle:Number, oldForDist:Number,
											  					newBackAngle:Number, newBackDist:Number, newForAngle:Number, newForDist:Number):void{
			var index:int = _pointList.firstIndexOf(from);
			if(index!=-1){
				linkBeziers();
				var bezier:Bezier = _bezierList.get(index);
				if(!isNaN(newForAngle))bezier.start.forwardAngle = newForAngle;
				if(!isNaN(newForDist))bezier.start.forwardDistance = newForDist;
				if(!isNaN(newBackAngle))bezier.start.backwardAngle = newBackAngle;
				if(!isNaN(newBackDist))bezier.start.backwardDistance = newBackDist;
				this.dispatchShapeChanged();
			}
		}
		protected function validateShape():void{
			if(invalidShape){
				linkBeziers();
				autoFill();
				_length = 0;
				var iterator:IIterator = _bezierList.getIterator();
				var bezier:Bezier;
				while(bezier = iterator.next()){
					_length += bezier.length;
				}
				iterator.release();
				invalidShape = false;
			}
		}
		public function getFractClosestTo(point:Point, tolerance:Number = 0.05):Distance{
			var totalLength:Number = length;
			var length:Number = 0;
			var nearest:Distance;
			var aveLength:Number = 0;
			var iterator:IIterator = _bezierList.getIterator();
			var bezier:Bezier;
			while(bezier = iterator.next()){
				aveLength = bezier.length;
			}
			aveLength /= _bezierList.length;
			iterator.release();
			iterator = _bezierList.getIterator();
			while(bezier = iterator.next()){
				var _nearest:Distance = bezier.getFractClosestTo(point, tolerance * (aveLength / bezier.length));
				if(_nearest && (!nearest || nearest.distance>_nearest.distance)){
					nearest = _nearest;
					nearest.fract = (length/totalLength)+(nearest.fract*(bezier.length/totalLength))
				}
				length += bezier.length;
			}
			iterator.release();
			return nearest;
		}
		private function dispatchShapeChanged(): void
		{
			if(_shapeChanged)_shapeChanged.perform(this);
		}
		public function clone():*{
			var ret:Path = Cloner.clone(this,false);
			var iterator:IIterator = getPointIterator();
			var point:BezierPoint;
			while(point = iterator.next()){
				ret.addPoint(point);
			}
			return ret;
		}
	}
}