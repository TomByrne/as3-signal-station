package org.tbyrne.acting.universal.rules
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.metadata.ruleTypes.IUniversalClassRule;
	import org.tbyrne.reflection.Deliterator;
	import org.tbyrne.reflection.ReflectionUtils;

	public class VersatileActRule extends PhasedActRule implements IUniversalClassRule
	{
		public function get actClass():Class{
			return _actClass;
		}
		public function set actClass(value:Class):void{
			_actClass = value;
		}
		public function get props():Object{
			return _props;
		}
		public function set props(value:Object):void{
			_props = value;
		}
		public function get instance():IUniversalAct{
			return _instance;
		}
		public function set instance(value:IUniversalAct):void{
			_instance = value;
		}
		
		private var _instance:IUniversalAct;
		private var _actClass:Class;
		private var _props:Object;
		
		public function VersatileActRule(actClass:Class=null, beforePhases:Array=null, afterPhases:Array=null){
			super(beforePhases, afterPhases);
			_actClass = actClass;
		}
		override public function shouldReact(act:IUniversalAct):Boolean{
			var classMatch:Boolean = (_actClass==null || (act is _actClass));
			var propsMatch:Boolean = true;
			if(classMatch && _props){
				for(var i:String in _props){
					if(act[i]!=_props[i]){
						propsMatch = false;
						break;
					}
				}
			}
			var instanceMatch:Boolean = (!_instance || _instance==act);
			return (classMatch && propsMatch && instanceMatch);
		}
	}
}