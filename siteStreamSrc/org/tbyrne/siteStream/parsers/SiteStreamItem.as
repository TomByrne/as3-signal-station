package org.tbyrne.siteStream.parsers
{
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;
	
	public class SiteStreamItem extends DefaultParser
	{
		public function get lazyProperties():Array{
			return _lazyProperties;
		}
		public function set lazyProperties(value:Array):void{
			if(_lazyProperties != value){
				_lazyProperties = value;
			}
		}
		
		private var _lazyProperties:Array;
		
		
		override public function parseLazily(propertyInfo:IPropertyInfo):Boolean{
			var explicitLazy:Boolean = (propertyInfo && _lazyProperties && _lazyProperties.indexOf(propertyInfo.propertyName)!=-1);
			return (explicitLazy || super.parseLazily(propertyInfo));
		}
	}
}