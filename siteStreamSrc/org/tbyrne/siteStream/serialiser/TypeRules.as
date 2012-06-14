package org.tbyrne.siteStream.serialiser
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.reflection.ReflectionUtils;
	
	public class TypeRules implements ITypeRules
	{
		
		public function get allowTypeAsLiteral():Boolean{
			return _allowTypeAsLiteral;
		}
		public function set allowTypeAsLiteral(value:Boolean):void{
			_allowTypeAsLiteral = value;
		}
		
		public function get ignoreProps():Array{
			return _ignoreProps;
		}
		public function set ignoreProps(value:Array):void{
			_ignoreProps = value;
		}
		
		public function get hexNumberProps():Array{
			return _hexNumberProps;
		}
		public function set hexNumberProps(value:Array):void{
			_hexNumberProps = value;
		}
		
		public function get defaultProps():Dictionary{
			return _defaultProps;
		}
		public function set defaultProps(value:Dictionary):void{
			_defaultProps = value;
		}
		
		public function get doSerialiseRule():Function{
			return _doSerialiseRule;
		}
		public function set doSerialiseRule(value:Function):void{
			_doSerialiseRule = value;
		}
		
		private var _doSerialiseRule:Function;
		private var _defaultProps:Dictionary;
		private var _hexNumberProps:Array;
		private var _ignoreProps:Array;
		private var _allowTypeAsLiteral:Boolean;
		
		public function TypeRules(ignoreProps:Array=null)
		{
			this.ignoreProps = ignoreProps;
		}
		
		public function autoCreateDefaults(newInstance:*):void{
			_defaultProps = new Dictionary();
			ReflectionUtils.callForMembers(newInstance,createDefault,true,false,true);
		}
		
		private function createDefault(parentObject:*, value:*, memberName:String, isMethod:Boolean, definedBy:Class, definedType:Class):Boolean{
			_defaultProps[memberName] = value;
			return false;
		}
		
		public function doSerialise(object:*):Boolean{
			if(_doSerialiseRule!=null){
				return _doSerialiseRule(object);
			}else{
				return true;
			}
		}
	}
}