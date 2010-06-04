package org.farmcode.sodalityLibrary.control.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.control.IControlScheme;
	import org.farmcode.sodalityLibrary.control.adviceTypes.IChangeControlAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;

	public class ChangeControlAdvice extends Advice implements IResolvePathsAdvice, IChangeControlAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get controlSchemePath():String{
			return _controlSchemePath;
		}
		public function set controlSchemePath(value:String):void{
			_controlSchemePath = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get controlScheme():IControlScheme{
			return _controlScheme;
		}
		public function set controlScheme(value:IControlScheme):void{
			_controlScheme = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get oldControlScheme():IControlScheme{
			return _oldControlScheme;
		}
		public function set oldControlScheme(value:IControlScheme):void{
			_oldControlScheme = value;
		}
		
		private var _oldControlScheme:IControlScheme;
		private var _controlScheme:IControlScheme;
		private var _controlSchemePath:String;
		
		
		public function ChangeControlAdvice(controlSchemePath:String=null, controlScheme:IControlScheme=null)
		{
			this.controlSchemePath = controlSchemePath;
			this.controlScheme = controlScheme;
		}
		
		public function get resolvePaths():Array{
			return _controlScheme?[]:[_controlSchemePath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			controlScheme = (value[_controlSchemePath] as IControlScheme);
		}
	}
}