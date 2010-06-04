package org.farmcode.sodalityLibrary.utils.config.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;

	public class SetPropertyConfigParamAdvice extends GetConfigParamAdvice implements IResolvePathsAdvice
	{
		[Property(toString="true",clonable="true")]
		public function set destinationPath(value:String):void{
			_destinationPath = value;
		}
		public function get destinationPath():String{
			return _destinationPath;
		}
		[Property(toString="true",clonable="true")]
		public function set destination(value:Object):void{
			_destination = value;
			if(this.value && _destination){
				_destination[destinationProperty] = this.value;
			}
		}
		public function get destination():Object{
			return _destination;
		}
		
		override public function set value(value:String):void{
			super.value = value;
			if(value && _destination){
				_destination[destinationProperty] = this.value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public var destinationProperty:String;
		
		private var _destinationPath:String;
		private var _destination:Object;
		
		public function SetPropertyConfigParamAdvice(destination:Object=null,destinationProperty:String=null, paramName:String=null){
			super(paramName);
			this.destinationProperty = destinationProperty;
			this.destination = destination;
		}
		
		public function get resolvePaths():Array{
			return destination?[]:[_destinationPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			var destination:Object = value[_destinationPath];
			if(destination)this.destination = destination;
		}
	}
}