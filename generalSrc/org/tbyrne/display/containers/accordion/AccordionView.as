package org.tbyrne.display.containers.accordion
{
	

	public class AccordionView extends AbstractAccordionView
	{
		public function get dataProvider():*{
			return _layout.dataProvider;
		}
		public function set dataProvider(value:*):void{
			if(_layout.dataProvider != value){
				_layout.dataProvider = value;
			}
		}
	}
}