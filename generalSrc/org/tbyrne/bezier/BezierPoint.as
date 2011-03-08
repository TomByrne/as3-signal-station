package org.tbyrne.bezier
{
	import flash.geom.Point;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	import org.tbyrne.hoborg.ReadableObjectDescriber;
	import org.tbyrne.math.Trigonometry;
	
	public class BezierPoint implements IPoolable
	{
		/*CONFIG::debug{
			private static var gettingNew:Boolean;
		}*/
		private static const pool:ObjectPool = new ObjectPool(BezierPoint);
		public static function getNew(x:Number=0, y:Number=0, angle:Number=NaN, distance:Number=NaN):BezierPoint{
			/*CONFIG::debug{
				gettingNew = true;
			}*/
			var ret:BezierPoint = pool.takeObject();
			ret.x = x;
			ret.y = y;
			ret.angle = angle;
			ret.distance = distance;
			/*CONFIG::debug{
				gettingNew = false;
			}*/
			return ret;
		}
		
		[Property(toString="true",clonable="true")]
		public function get x():Number{
			return _x;
		}
		public function set x(value:Number):void{
			if(value!=_x){
				var oldX:Number = _x;
				_x = value;
				if(_positionChanged)_positionChanged.perform(this,oldX,_y,_x,_y);
			}
		}
		[Property(toString="true",clonable="true")]
		public function get y():Number{
			return _y;
		}
		public function set y(value:Number):void{
			if(value!=_y){
				var oldY:Number = _y;
				_y = value;
				if(_positionChanged)_positionChanged.perform(this,_x,oldY,_x,_y);
			}
		}
		public function get backwardAngle():Number{
			if(_numbersInvalid)validateNumbers();
			return _backwardAngle;
		}
		public function set backwardAngle(value:Number):void{
			if(_numbersInvalid)validateNumbers();
			if(value!=_backwardAngle){
				if(_vectorChanged){
					var oldBackVector:Point = backwardVector
				}
				if(_angleDistanceChanged){
					var oldBackAngle:Number = backwardAngle;
				}
				_backwardAngle = value;
				_pointsInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, oldBackVector, forwardVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, oldBackAngle, backwardDistance, forwardAngle, forwardDistance,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		public function get backwardDistance():Number{
			if(_numbersInvalid)validateNumbers();
			return _backwardDistance;
		}
		public function set backwardDistance(value:Number):void{
			if(_numbersInvalid)validateNumbers();
			value = Math.abs(value);
			if(value!=_backwardDistance){
				if(_vectorChanged){
					var oldBackVector:Point = backwardVector;
				}
				if(_angleDistanceChanged){
					var oldBackDistance:Number = backwardDistance;
				}
				_backwardDistance = value;
				_pointsInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, oldBackVector, forwardVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, backwardAngle, oldBackDistance, forwardAngle, forwardDistance,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		public function get forwardAngle():Number{
			if(_numbersInvalid)validateNumbers();
			return _forwardAngle;
		}
		public function set forwardAngle(value:Number):void{
			if(_numbersInvalid)validateNumbers();
			if(value!=_forwardAngle){
				if(_vectorChanged){
					var oldForVector:Point = forwardVector;
				}
				if(_angleDistanceChanged){
					var oldForAngle:Number = forwardAngle;
				}
				_forwardAngle = value;
				_pointsInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, backwardVector, oldForVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, backwardAngle, backwardDistance, oldForAngle, forwardDistance,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		public function get forwardDistance():Number{
			if(_numbersInvalid)validateNumbers();
			return _forwardDistance;
		}
		public function set forwardDistance(value:Number):void{
			if(_numbersInvalid)validateNumbers();
			value = Math.abs(value);
			if(value!=_forwardDistance){
				if(_vectorChanged){
					var oldForVector:Point = forwardVector;
				}
				if(_angleDistanceChanged){
					var oldForDist:Number = forwardDistance;
				}
				_forwardDistance = value;
				_pointsInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, backwardVector, oldForVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, backwardAngle, backwardDistance, forwardAngle, oldForDist,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		public function get angle():Number{
			if(_numbersInvalid)validateNumbers();
			return (_backwardAngle==(_forwardAngle+180)%360?_forwardAngle:NaN);
		}
		public function set angle(value:Number):void{
			if(_numbersInvalid)validateNumbers();
			if(value!=angle){
				if(_vectorChanged){
					var oldForVector:Point = forwardVector;
					var oldBackVector:Point = backwardVector;
				}
				if(_angleDistanceChanged){
					var oldForAngle:Number = forwardAngle;
					var oldBackAngle:Number = backwardAngle;
				}
				_backwardAngle = (value+180)%360;
				_forwardAngle = value;
				_pointsInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, oldBackVector, oldForVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, oldBackAngle, backwardDistance, oldForAngle, forwardDistance,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		public function get distance():Number{
			if(_numbersInvalid)validateNumbers();
			return (_backwardDistance==_forwardDistance?_backwardDistance:NaN);
		}
		public function set distance(value:Number):void{
			if(_numbersInvalid)validateNumbers();
			value = Math.abs(value);
			if(value!=distance){
				if(_vectorChanged){
					var oldForVector:Point = forwardVector;
					var oldBackVector:Point = backwardVector;
				}
				if(_angleDistanceChanged){
					var oldForDist:Number = forwardDistance;
					var oldBackDist:Number = backwardDistance;
				}
				_backwardDistance = _forwardDistance = value;
				_pointsInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, oldBackVector, oldForVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, backwardAngle, oldBackDist, forwardAngle, oldForDist,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		[Property(toString="true",clonable="true")]
		public function get forwardVector():Point{
			if(_pointsInvalid)validatePoints();
			return _forwardVector;
		}
		public function set forwardVector(value:Point):void{
			if(_pointsInvalid)validatePoints();
			if((!_forwardVector && value) || (_forwardVector && (!value || !_forwardVector.equals(value)))){
				if(_vectorChanged){
					var oldForVector:Point = forwardVector;
				}
				if(_angleDistanceChanged){
					var oldForDist:Number = forwardDistance;
					var oldForAngle:Number = forwardAngle;
				}
				_forwardVector = value;
				_numbersInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, backwardVector, oldForVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, backwardAngle, backwardDistance, oldForAngle, oldForDist,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		[Property(toString="true",clonable="true")]
		public function get backwardVector():Point{
			if(_pointsInvalid)validatePoints();
			return _backwardVector;
		}
		public function set backwardVector(value:Point):void{
			if(_pointsInvalid)validatePoints();
			if((!_backwardVector && value) || (_backwardVector && (!value || !_backwardVector.equals(value)))){
				if(_vectorChanged){
					var oldBackVector:Point = backwardVector;
				}
				if(_angleDistanceChanged){
					var oldBackDist:Number = backwardDistance;
					var oldBackAngle:Number = backwardAngle;
				}
				_backwardVector = value;
				_numbersInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, oldBackVector, forwardVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, oldBackAngle, oldBackDist, forwardAngle, forwardDistance,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		public function get vector():Point{
			if(_pointsInvalid)validatePoints();
			if(_backwardVector && _forwardVector){
				var back:Point = new Point(x-(_backwardVector.x-x),y-(_backwardVector.y-y));
				return back.equals(_forwardVector)?back:null;
			}else{
				return null;
			}
		}
		public function set vector(value:Point):void{
			if(_pointsInvalid)validatePoints();
			if((!vector && value) || (vector && (!value || !vector.equals(value)))){
				if(_vectorChanged){
					var oldForVector:Point = forwardVector;
					var oldBackVector:Point = backwardVector;
				}
				if(_angleDistanceChanged){
					var oldBackAngle:Number = backwardAngle;
					var oldBackDist:Number = backwardDistance;
					var oldForAngle:Number = forwardAngle;
					var oldForDist:Number = forwardDistance;
				}
				_forwardVector = value;
				_backwardVector = new Point(x-(value.x-x),y-(value.y-y));
				_numbersInvalid = true;
				if(_vectorChanged){
					_vectorChanged.perform(this, oldBackVector, oldForVector, backwardVector, forwardVector);
				}
				if(_angleDistanceChanged){
					_angleDistanceChanged.perform(this, oldBackAngle, oldBackDist, oldForAngle, oldForDist,
														backwardAngle, backwardDistance, forwardAngle, forwardDistance);
				}
			}
		}
		
		
		/**
		 * handler(from:BezierPoint, oldX:Number, oldY:Number, newX:Number, newY:Number)
		 */
		public function get positionChanged():IAct{
			if(!_positionChanged)_positionChanged = new Act();
			return _positionChanged;
		}
		
		/**
		 * handler(from:BezierPoint, oldBackVector:Point, oldForVector:Point, newBackVector:Point, newForVector:Point)
		 */
		public function get vectorChanged():IAct{
			if(!_vectorChanged)_vectorChanged = new Act();
			return _vectorChanged;
		}
		
		/**
		 * handler(from:BezierPoint, oldBackAngle:Number, oldBackDist:Number, oldForAngle:Number, oldForDist:Number,
		 * 								newBackAngle:Number, newBackDist:Number, newForAngle:Number, newForDist:Number)
		 */
		public function get angleDistanceChanged():IAct{
			if(!_angleDistanceChanged)_angleDistanceChanged = new Act();
			return _angleDistanceChanged;
		}
		
		protected var _angleDistanceChanged:Act;
		protected var _vectorChanged:Act;
		protected var _positionChanged:Act;
		
		private var _x:Number;
		private var _y:Number;
		
		private var _backwardAngle:Number;
		private var _backwardDistance:Number;
		private var _forwardAngle:Number;
		private var _forwardDistance:Number;
		
		private var _forwardVector:Point;
		private var _backwardVector:Point;
		private var _bothVector:Point;
		
		private var _pointsInvalid:Boolean = true;
		private var _numbersInvalid:Boolean = false;
		
		public function BezierPoint(x:Number=0, y:Number=0, angle:Number=NaN, distance:Number=NaN){
			/*CONFIG::debug{
				if(!gettingNew && this["constructor"]==BezierPoint)Log.error("BezierPoint should be created via BezierPoint.getNew()");
			}*/
			this.x = x;
			this.y = y;
			this.angle = angle;
			this.distance = distance;
		}
		public function validateNumbers():void{
			var thisPoint:Point = new Point(x,y);
			if(_backwardVector){
				_backwardAngle = Trigonometry.getAngleTo(thisPoint.x,thisPoint.y,_backwardVector.x,_backwardVector.y);
				_backwardDistance = Trigonometry.getDirection(thisPoint.x,thisPoint.y,_backwardVector.x,_backwardVector.y);
			}else{
				_backwardAngle = _backwardDistance = NaN;
			}
			if(_forwardVector){
				_forwardAngle = Trigonometry.getAngleTo(thisPoint.x,thisPoint.y,_forwardVector.x,_forwardVector.y);
				_forwardDistance = Trigonometry.getDirection(thisPoint.x,thisPoint.y,_forwardVector.x,_forwardVector.y);
			}else{
				_forwardAngle = _forwardDistance = NaN;
			}
			_numbersInvalid = false;
		}
		public function validatePoints():void{
			if(!isNaN(_forwardDistance) && !isNaN(_forwardAngle))_forwardVector = Trigonometry.projectPoint(_forwardDistance,_forwardAngle,0,0);
			else _forwardVector = null;
			if(!isNaN(_backwardDistance) && !isNaN(_backwardAngle))_backwardVector = Trigonometry.projectPoint(_backwardDistance,_backwardAngle,0,0);
			else _backwardVector = null;
			_pointsInvalid = false;
		}
		public function clone():BezierPoint{
			var ret:BezierPoint = BezierPoint.getNew();
			ret.x = x;
			ret.y = y;
			if(!_pointsInvalid){
				ret.forwardVector = _forwardVector;
				ret.backwardVector = _backwardVector;
			}else{
				ret.forwardAngle = forwardAngle;
				ret.forwardDistance = forwardDistance;
				ret.backwardAngle = backwardAngle;
				ret.backwardDistance = backwardDistance;
			}
			return ret;
		}
		public function equals(toCompare:BezierPoint):Boolean{
			var posMatch:Boolean = (x==toCompare.x && y==toCompare.y);
			return (toCompare.forwardAngle==forwardAngle && 
					toCompare.forwardDistance==forwardDistance && 
					toCompare.backwardAngle==backwardAngle && 
					toCompare.backwardDistance==backwardDistance);
		}
		public function add(point:*):Point{
			if(point is Point || point is BezierPoint){
				return new Point(x+point.x,y+point.y);
			}
			return null;
		}
		public function toPoint():Point{
			return new Point(x,y);
		}
		public function toString():String{
			return ReadableObjectDescriber.describe(this);
		}
		public function reset():void{
			_x = NaN;
			_y = NaN;
		
			_backwardAngle = NaN;
			_backwardDistance = NaN;
			_forwardAngle = NaN;
			_forwardDistance = NaN;
		
			_forwardVector = null;
			_backwardVector = null;
			_bothVector = null;
		
			_pointsInvalid = true;
			_numbersInvalid = false;
			
			if(_positionChanged)_positionChanged.removeAllHandlers();
			if(_angleDistanceChanged)_angleDistanceChanged.removeAllHandlers();
			if(_vectorChanged)_vectorChanged.removeAllHandlers();
		}
		public function release():void{
			pool.releaseObject(this);
		}
		
		public function setPosition(x:Number, y:Number):void{
			if(_x!=x || _y!=y){
				var oldX:Number = _x;
				var oldY:Number = _y;
				_x = x;
				_y = y;
				if(_positionChanged)_positionChanged.perform(this,oldX,oldY,_x,_y);
			}
		}
	}
}