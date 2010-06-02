package org.farmcode.memory{
	import flash.net.LocalConnection;
	
	/**
	 * This is Grant Skinner's <a href="http://www.gskinner.com/blog/archives/2006/08/as3_resource_ma_2.html">
	 * hack</a> to force garbage collection.
	 */
	public function garbageCollect():void{
		try {
		   new LocalConnection().connect('foo');
		   new LocalConnection().connect('foo');
		} catch (e:*) {}
	}
}

