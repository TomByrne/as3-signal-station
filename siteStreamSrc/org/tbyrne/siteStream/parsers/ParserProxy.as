package org.tbyrne.siteStream.parsers
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.siteStream.SiteStreamNamespace;
	import org.tbyrne.siteStream.SiteStreamNode;
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;
	
	use namespace SiteStreamNamespace;

	public class ParserProxy implements ISiteStreamParser
	{
		
		/**
		 * @inheritDoc
		 */
		public function get dataLoadFailure():IAct{
			return (_dataLoadFailure || (_dataLoadFailure = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get classLoadFailure():IAct{
			return (_classLoadFailure || (_classLoadFailure = new Act()));
		}
		
		protected var _classLoadFailure:Act;
		protected var _dataLoadFailure:Act;
		
		
		
		public function get siteStreamItem():ISiteStreamParser{
			return _siteStreamItem;
		}
		public function set siteStreamItem(value:ISiteStreamParser):void{
			if(_siteStreamItem){
				_siteStreamItem.classLoadFailure.removeHandler(onClassLoadFailure);
				_siteStreamItem.dataLoadFailure.removeHandler(onDataLoadFailure);
			}
			_siteStreamItem = value;
			if(_siteStreamItem){
				_siteStreamItem.classLoadFailure.addHandler(onClassLoadFailure);
				_siteStreamItem.dataLoadFailure.addHandler(onDataLoadFailure);
			}
		}
		
		private function onDataLoadFailure():void{
			if(_dataLoadFailure)_dataLoadFailure.perform(this);
		}
		private function onClassLoadFailure():void{
			if(_classLoadFailure)_classLoadFailure.perform(this);
		}
		public function set parentParser(value:ISiteStreamParser):void{
			_siteStreamItem.parentParser = value;
		}
		
		private var _siteStreamItem:ISiteStreamParser;
		
		public function ParserProxy(siteStreamItem:ISiteStreamParser=null){
			this.siteStreamItem = siteStreamItem;
		}
		
		
		public function isDataLoaded(propInfo:IPropertyInfo):Boolean{
			return siteStreamItem.isDataLoaded(propInfo);
		}
		public function loadData(propInfo:IPropertyInfo):IPendingResult{
			return siteStreamItem.loadData(propInfo);
		}
		public function releaseData(propInfo:IPropertyInfo):Boolean{
			return siteStreamItem.releaseData(propInfo);
		}
		public function isClassLoaded(propInfo:IPropertyInfo):Boolean{
			return siteStreamItem.isClassLoaded(propInfo);
		}
		public function loadClass(propInfo:IPropertyInfo):IPendingResult{
			return siteStreamItem.loadClass(propInfo);
		}
		public function releaseClass(propInfo:IPropertyInfo):void{
			siteStreamItem.releaseClass(propInfo);
		}
		public function getNodeReference(propInfo:IPropertyInfo):String{
			return siteStreamItem.getNodeReference(propInfo);
		}
		public function createObject(propertyInfo:IPropertyInfo):IPendingResult{
			return siteStreamItem.createObject(propertyInfo);
		}
		public function getChildProperties(propertyInfo:IPropertyInfo):Array{
			return siteStreamItem.getChildProperties(propertyInfo);
		}
		public function parseLazily(propertyInfo:IPropertyInfo):Boolean{
			return siteStreamItem.parseLazily(propertyInfo);
		}
		public function commitValue(propertyInfo:IPropertyInfo, node:SiteStreamNode):void{
			siteStreamItem.commitValue(propertyInfo, node);
		}
		public function compareChildIds(id1:String,id2:String):Boolean{
			return siteStreamItem.compareChildIds(id1,id2);
		}
		public function createNewPropertyInfo():IPropertyInfo{
			return siteStreamItem.createNewPropertyInfo();
		}
		public function initPropertyInfo(propertyInfo:IPropertyInfo):void{
			siteStreamItem.initPropertyInfo(propertyInfo);
		}
	}
}