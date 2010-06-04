package org.farmcode.sodalityPlatformEngine.physics.advice
{
	import Box2D.Dynamics.b2Body;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IAddContactListenerAdvice;

	public class AbstractContactListenerAdvice extends Advice
	{
		[Property(toString="true",clonable="true")]
		public function get contactHandler():Function{
			return _contactHandler;
		}
		public function set contactHandler(value:Function):void{
			_contactHandler = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get contactBodies():Array{
			return _contactBodies;
		}
		public function set contactBodies(value:Array):void{
			_contactBodies = value;
		}
		
		private var _contactBodies:Array;
		private var _contactHandler:Function;
		
		public function AbstractContactListenerAdvice(contactHandler:Function=null, contactBodies:Array=null){
			super();
			this.contactHandler = contactHandler;
			this.contactBodies = contactBodies;
		}
		
	}
}