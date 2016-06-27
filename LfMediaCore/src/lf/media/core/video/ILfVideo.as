package lf.media.core.video
{
	import flash.net.NetStream;
	
	/**
	 * 接口:video 内核
	 * 
	 * @author mj
	 * 
	 */
		
	public interface ILfVideo
	{
		
		function creat(config:Object = null):void;
		function play(url:String):void;
		function pause():void;
		function resume():void;
		function stop():void;
		function resize(width:int,height:int):void;
		
		function set setSmoothing(value:Boolean):void;
		
		function set volume(value:Number):void;
		function get volume():Number;
		function get netStream():NetStream;
		
		function get mediaType():String;
		
		
		function destroy():void;
	}
	
	
}