package org.farmcode.actLibrary.external.config.acts
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.external.siteStream.actTypes.IResolvePathsAct;

	public class SetPropertyConfigParamAct extends GetConfigParamAct implements IResolvePathsAct
	{
		public function set destinationPath(value:String):void{
			_destinationPath = value;
		}
		public function get destinationPath():String{
			return _destinationPath;
		}
		public function set destination(value:Object):void{
			_destination = value;
			if(this.value && _destination){
				_destination[destinationProperty] = this.value;
			}
		}
		public function get destination():Object{
			return _destination;
		}
		
		override public function set value(value:*):void{
			super.value = value;
			if(value && _destination){
				_destination[destinationProperty] = this.value;
			}
		}
		
		public function get resolveSuccessful():Boolean{
			return _resolveSuccessful;
		}
		public function set resolveSuccessful(value:Boolean):void{
			_resolveSuccessful = value;
		}
		
		private var _resolveSuccessful:Boolean;
		public var destinationProperty:String;
		
		private var _destinationPath:String;
		private var _destination:Object;
		
		public function SetPropertyConfigParamAct(destination:Object=null,destinationProperty:String=null, paramName:String=null){
			super(paramName);
			this.destinationProperty = destinationProperty;
			this.destination = destination;
		}
		
		public function get resolvePaths():Array{
			return destination?[]:[_destinationPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			var destination:Object = value[_destinationPath];
			if(destination)this.destination = destination;
		}
	}
}