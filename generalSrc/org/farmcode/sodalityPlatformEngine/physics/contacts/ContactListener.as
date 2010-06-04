package org.farmcode.sodalityPlatformEngine.physics.contacts
{
	import Box2D.Collision.b2ContactPoint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.IIterator;
	import org.farmcode.collections.linkedList.LinkedList;

	public class ContactListener extends b2ContactListener
	{
		public static const ADD_EVENT:String = "addEvent";
		public static const REMOVE_EVENT:String = "removeEvent";
		
		private var allBodies:LinkedList = new LinkedList();
		private var someBodies:Dictionary = new Dictionary(true);
		
		override public function Add(point:b2ContactPoint) : void{
			executeHandlers(ADD_EVENT,allBodies,point);
			var list1:LinkedList = someBodies[point.shape1.GetBody()];
			if(list1)executeHandlers(ADD_EVENT,list1,point);
			var list2:LinkedList = someBodies[point.shape2.GetBody()];
			if(list2)executeHandlers(ADD_EVENT,list2,point);
		}
	
		override public function Remove(point:b2ContactPoint) : void{
			executeHandlers(REMOVE_EVENT,allBodies,point);
			var list1:LinkedList = someBodies[point.shape1.GetBody()];
			if(list1)executeHandlers(REMOVE_EVENT,list1,point);
			var list2:LinkedList = someBodies[point.shape2.GetBody()];
			if(list2)executeHandlers(REMOVE_EVENT,list2,point);
		}
		protected function executeHandlers(event:String, list:LinkedList, point:b2ContactPoint):void{
			var iterator:IIterator = list.getIterator();
			while(iterator.next()){
				(iterator.current() as Function)(event,point);
			}
			iterator.release();
		}
		
		public function addContactListener(handler:Function, bodies:Array=null):void{
			if(bodies){
				for each(var body:b2Body in bodies){
					var list:LinkedList = someBodies[body];
					if(!list){
						list = someBodies[body] = new LinkedList();
					}
					list.unshift(handler);
				}
			}else{
				allBodies.unshift(handler);
			}
		}
		public function removeContactListener(handler:Function, bodies:Array=null):void{
			if(bodies){
				for each(var body:b2Body in bodies){
					var list:LinkedList = someBodies[body];
					if(list){
						list.removeFirst(handler);
					}
				}
			}else{
				allBodies.removeFirst(handler);
			}
		}
		public function destroy():void{
			allBodies = new LinkedList();
			someBodies = new Dictionary(true);
		}
		
		
		/*
		// not implemented yet (for performance)
		override public function Persist(point:b2ContactPoint) : void{
		}
		override public function Result(point:b2ContactResult) : void{
		}*/
	}
}