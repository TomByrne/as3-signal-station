package org.farmcode.actLibrary.external.siteStream.acts
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.external.siteStream.actTypes.IResolvePathsAct;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.utils.ObjectUtils;
	
	public class SetPropertySiteStreamAct extends UniversalAct implements IResolvePathsAct
	{
		private static const SOURCE_PROP: String = "source";
		private static const DESTINATION_PROP: String = "destination";
		
		protected var _destination: Object;
		protected var _destinationProperties: Array;
		protected var _destinationPath: String;
		
		protected var _source: *;
		protected var _sourceProperties: Array;
		protected var _sourcePath: String;
		
		public function SetPropertySiteStreamAct(){
		}
		
		public function get destinationPath(): String{
			return this._destinationPath;
		}
		public function set destinationPath(destinationPath: String): void{
			this._destinationPath = destinationPath;
		}
		
		public function get destination(): Object{
			return this._destination;
		}
		public function set destination(destination: Object): void{
			this._destination = destination;
		}
		
		public function get destinationProperties(): Array{
			return this._destinationProperties;
		}
		public function set destinationProperties(value: Array): void{
			this._destinationProperties = value;
		}
		
		public function get sourcePath(): String{
			return this._sourcePath;
		}
		public function set sourcePath(sourcePath: String): void{
			this._sourcePath = sourcePath;
		}
		
		public function get source(): *{
			return this._source;
		}
		public function set source(source: *): void{
			this._source = source;
		}
	
		public function get sourceProperties(): Array{
			return this._sourceProperties;
		}
		public function set sourceProperties(value: Array): void{
			this._sourceProperties = value;
		}
		public function get resolvePaths():Array{
			var ret:Array = (!_destinationPath || destination)?[]:[_destinationPath];
			if(_sourcePath && !source)ret.push(_sourcePath);
			return ret;
		}
		public function set resolvedObjects(value:Dictionary):void{
			var destination:Object = value[_destinationPath];
			if(destination)this.destination = destination;
			var source:* = value[_sourcePath];
			if(source)this.source = source;
		}
		
		override protected function _execute(cause:IAdvice, time:String):void
		{
			if (this.destination == null)
			{
				throw new ArgumentError("Destination object cannot be null");
			}
			if (this.destinationProperties.length != this.sourceProperties.length)
			{
				throw new ArgumentError("Both sets of properties must have equal lengths");
			}
			for (var i: uint = 0; i < this.sourceProperties.length; ++i)
			{
				var sourceProp: String = this.sourceProperties[i];
				var destProp: String = this.destinationProperties[i];
				ObjectUtils.setProperty(destination,destProp,ObjectUtils.getProperty(source,sourceProp));
			}
			
			super._execute(cause, time);
		}
	}
}