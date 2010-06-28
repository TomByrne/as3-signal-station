package org.farmcode.display.containers.accordion
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.layout.IMinimisableLayoutSubject;
	
	public interface IAccordionRenderer extends ILayoutView, IMinimisableLayoutSubject{
		
		/**
		 * handler(from:IAccordionRenderer)
		 */
		function get userChangedOpen():IAct;
		function set data(value:IBooleanProvider):void;
		function setOpen(value:Boolean):void;
	}
}