package lf.media.core.control.stream
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import lf.media.core.model.flv.HeadTag;
	

	public class FlvHeadTagC
	{
		public function FlvHeadTagC()
		{
		}
		
		public function init(sourceB:URLStream,buffer:ByteArray):void{
			this._buffer = buffer;
			this._sourceB = sourceB;
		}
		
		/**return 0:是Flv头   1：不是FLV 头   2：数据不够*/
		public function get  isFlvHead():int{
			if(_sourceB.bytesAvailable<3)	{
				return 2;
			}		
			
			if(_buffer.bytesAvailable<3){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,3-_buffer.bytesAvailable);
			}
			_buffer.position = 0;
			var str:String = "";
			str += _buffer.readByte().toString(16);
			str += _buffer.readByte().toString(16);
			str += _buffer.readByte().toString(16);
			_buffer.position = 0;
			return str == "464c56"? 0:1;
		}
		
		
		public function get tagData():HeadTag{
			var ht:HeadTag = new HeadTag();
			var b:ByteArray = new ByteArray();
			
			if(_buffer.bytesAvailable< ht.size){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,ht.size-_buffer.bytesAvailable);
			}
			
			_buffer.position = 0;
			ht.pos = ht.size;
			_buffer.readBytes(b,0,ht.size);
			ht.data = b;
			_buffer.position = ht.size;
			//print();
			return ht;
		}
		
		
		
		public function print():void{
			var str:String = "head data=";
			for(var i:int=0; i<_buffer.length; i++){
				str += _buffer[i].toString(16)+"|";
			}
			_buffer.position = 0;
			trace(str);
			
		}
		
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		
		
	}
}