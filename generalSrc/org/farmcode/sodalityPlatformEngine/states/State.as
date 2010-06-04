package org.farmcode.sodalityPlatformEngine.states
{
	
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	public class State
	{
		[Property(toString="true",clonable="true")]
		public function get id():String{
			return _id;
		}
		public function set id(value:String):void{
			if(value!=_id){
				_id = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get basedOn():State{
			return _basedOn;
		}
		public function set basedOn(value:State):void{
			if(value!=_basedOn){
				_basedOn = value;
			}
		}
		
		[Property(toString="false",clonable="true")]
		public function get propertyActions():Dictionary{
			return _propertyActions;
		}
		public function set propertyActions(value:Dictionary):void{
			if(value!=this.propertyActions){
				_propertyActions = value;
			}
		}
		
		private var _id:String;
		private var _basedOn:State;
		private var _propertyActions:Dictionary;
		
		public function State()
		{
			
		}
		
		public function getLineage(terminalParent: State = null): Array
		{
			var lineage: Array = new Array();
			lineage.push(this);
			if (terminalParent != this)
			{
				var currentParent: State = this.basedOn;
				while (currentParent != null && currentParent != terminalParent)
				{
					lineage.push(currentParent);
					currentParent = currentParent.basedOn;
				}
			}
			return lineage;
		}
		
		public function getActionsForProperty(property: String): Array
		{
			return this.propertyActions[property];
		}
		
		public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}