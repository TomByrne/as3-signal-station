package org.tbyrne.display.containers.accordion
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.IMinimisableLayoutSubject;
	
	public interface IAccordionRenderer extends ILayoutView, IMinimisableLayoutSubject{
		
		/**
		 * handler(from:IAccordionRenderer)
		 */
		function get userChangedOpen():IAct;
		function set data(value:IBooleanProvider):void;
		function setOpen(value:Boolean):void;
	}
}