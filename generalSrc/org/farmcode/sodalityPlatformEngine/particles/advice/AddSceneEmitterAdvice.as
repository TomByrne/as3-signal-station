package org.farmcode.sodalityPlatformEngine.particles.advice
{
	import org.farmcode.sodalityPlatformEngine.particles.adviceTypes.IAddSceneEmitterAdvice;
	
	import org.farmcode.sodality.advice.Advice;
	import org.flintparticles.threeD.emitters.Emitter3D;

	public class AddSceneEmitterAdvice extends Advice implements IAddSceneEmitterAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get minX():Number{
			return _minX;
		}
		public function set minX(value:Number):void{
			_minX = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get maxX():Number{
			return _maxX;
		}
		public function set maxX(value:Number):void{
			_maxX = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get minY():Number{
			return _minY;
		}
		public function set minY(value:Number):void{
			_minY = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get maxY():Number{
			return _maxY;
		}
		public function set maxY(value:Number):void{
			_maxY = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get nearDistance():Number{
			return _minZ;
		}
		public function set nearDistance(value:Number):void{
			_minZ = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get farDistance():Number{
			return _maxZ;
		}
		public function set farDistance(value:Number):void{
			_maxZ = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get fillEdge():String{
			return _fillEdge;
		}
		public function set fillEdge(value:String):void{
			_fillEdge = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get fillRate():Number{
			return _fillRate;
		}
		public function set fillRate(value:Number):void{
			_fillRate = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get initialFill():Number{
			return _initialFill;
		}
		public function set initialFill(value:Number):void{
			_initialFill = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get particleImageClass():Class{
			return _particleImageClass;
		}
		public function set particleImageClass(value:Class):void{
			_particleImageClass = value;
		}
		[Property(toString="true",clonable="true")]
		public function get doBounding():Boolean{
			return _doBounding;
		}
		public function set doBounding(value:Boolean):void{
			_doBounding = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get initializers():Array{
			return _initializers;
		}
		public function set initializers(value:Array):void{
			_initializers = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get emitter():Emitter3D{
			return _emitter;
		}
		public function set emitter(value:Emitter3D):void{
			_emitter = value;
		}
		[Property(toString="true",clonable="true")]
		public function get actions():Array{
			return _actions;
		}
		public function set actions(value:Array):void{
			_actions = value;
		}
		
		private var _maxZ:Number;
		private var _minZ:Number;
		private var _maxY:Number;
		private var _minY:Number;
		private var _maxX:Number;
		private var _minX:Number;
		
		private var _doBounding:Boolean;
		private var _particleImageClass:Class;
		private var _initialFill:Number;
		private var _fillRate:Number;
		private var _fillEdge:String;
		
		private var _emitter:Emitter3D;
		private var _initializers:Array;
		private var _actions:Array;
		
		public function AddSceneEmitterAdvice(){
			super();
		}
		
	}
}