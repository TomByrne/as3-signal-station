package org.farmcode.sodalityLibrary.external.siteStream.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	
	public class SetPropertySiteStreamAdvice extends Advice implements IResolvePathsAdvice
	{
		private static const SOURCE_PROP: String = "source";
		private static const DESTINATION_PROP: String = "destination";
		
		protected var _destination: Object;
		protected var _destinationProperties: Array;
		protected var _destinationPath: String;
		
		protected var _source: *;
		protected var _sourceProperties: Array;
		protected var _sourcePath: String;
		
		public function SetPropertySiteStreamAdvice(){
		}
		
		[Property(toString="true",clonable="true")]
		public function get destinationPath(): String{
			return this._destinationPath;
		}
		public function set destinationPath(destinationPath: String): void{
			this._destinationPath = destinationPath;
		}
		
		[Property(toString="true",clonable="true")]
		public function get destination(): Object{
			return this._destination;
		}
		public function set destination(destination: Object): void{
			this._destination = destination;
		}
		
		[Property(toString="true",clonable="true")]
		public function get destinationProperties(): Array{
			return this._destinationProperties;
		}
		public function set destinationProperties(value: Array): void{
			this._destinationProperties = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get sourcePath(): String{
			return this._sourcePath;
		}
		public function set sourcePath(sourcePath: String): void{
			this._sourcePath = sourcePath;
		}
		
		[Property(toString="true",clonable="true")]
		public function get source(): *{
			return this._source;
		}
		public function set source(source: *): void{
			this._source = source;
		}
		
		[Property(toString="true",clonable="true")]
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
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			var destination:Object = value[_destinationPath];
			if(destination)this.destination = destination;
			var source:* = value[_sourcePath];
			if(source)this.source = source;
		}
		
		protected function getSourceValue(prop: String): *
		{
			if (prop != null && prop.length)
			{
				var subject:* = source;
				var remaining:String = prop;
				var index:Number = remaining.indexOf(".");
				while(index!=-1){
					subject = subject[remaining.substr(0,index)];
					remaining = remaining.substr(index+1);
					index = remaining.indexOf(".");
				}
				
				return subject[remaining];
			}
			return source;
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
				this.destination[destProp] = this.getSourceValue(sourceProp);
			}
			
			super._execute(cause, time);
		}
	}
}