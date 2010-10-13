package org.tbyrne.display.assets.stylable.styles
{
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;

	public class AbstractStyle implements IStyle
	{
		public function get pathPattern():String{
			return _pathPattern;
		}
		public function set pathPattern(value:String):void{
			if(_pathPattern!=value){
				_pathPattern = value;
				_pathRegExp = new RegExp(_pathPattern,"");
			}
		}
		
		public function get stateName():String{
			return _stateName;
		}
		public function set stateName(value:String):void{
			_stateName = value;
		}
		
		private var _stateName:String;
		private var _pathPattern:String;
		private var _pathRegExp:RegExp;
		
		
		public function AbstractStyle(pathPattern:String=null, stateName:String=null){
			this.pathPattern = pathPattern;
			this.stateName = stateName;
		}
		public function matchesSchema(schema:IAssetSchema, otherStyles:Array):Boolean{
			for each(var style:IStyle in otherStyles){
				if(isOverridenBy(style))return false;
			}
			return _pathRegExp.test(schema.assetPath);
		}
		public function allowConcurrentWith(currStyles:Array):Boolean{
			for each(var style:IStyle in currStyles){
				if(!canConcurrentApply(style))return false;
			}
			return true;
		}
		/**
		 * Should return false if this style can apply to the same asset as the otherStyle property.
		 * Styles that apply to different states should return false (they do not conflict).
		 */
		protected function isOverridenBy(otherStyle:IStyle):Boolean{
			return false;
		}
		/**
		 * Should return true if this style should be applied to the asset, taking into account
		 * it's state.
		 */
		protected function canConcurrentApply(otherStyle:IStyle):Boolean{
			return false;
		}
	}
}