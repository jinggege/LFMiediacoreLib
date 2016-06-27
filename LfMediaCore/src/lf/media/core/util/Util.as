package lf.media.core.util
{
	import com.adobe.json.JSON;
	import com.adobe.json.JSONDecoder;
	
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import lf.media.core.data.ValidateVO;

	public class Util
	{
		
	/**
	 * 获取TextField 真实的宽度
	 * @param tf :TextField
	 */
		public static function getTfWidth(tf:TextField):int{
			var str:String = tf.text;
			var rec:Rectangle;
			var w:int = 0;
			
			for(var i:int=0; i<str.length; i++){
				rec = tf.getCharBoundaries(i);
				w += rec.width;
				rec = null;
			}
			return w;
		}
		
		
		public static function get getTime():Number{
			return new Date().getTime();
		}
		
		
		/**
		 * 验证json 串  
		 * @param: jsonStr json 串 
		 * @param:args  要验证的字段
		 * @return ValidateVO
		 */
		public static function validateJson(jsonStr:String, ...args):ValidateVO{
			
			if(jsonStr==""){
				return new ValidateVO(false,"error:json string is empty!")
			}
			
			var errMsg:String ="";
			for(var i:int=0; i<args.length; i++){
				if(jsonStr.indexOf(args[i])== -1){
					errMsg = "error:no ["+args[i]+"] init json string="+jsonStr;
					return new ValidateVO(false,errMsg)
				}
			}
			
			var obj:Object = null;
			
			try{
				obj = com.adobe.json.JSON.decode(jsonStr);
			}catch(err:Error){
				errMsg = "error:"+err.message+" string="+jsonStr;
				return new ValidateVO(false,errMsg)
			}
			return new ValidateVO(true,obj);
		}
		
		
		/**
		 * 获得字符串的字节长度
		 * @param str
		 * @param charSet
		 * @return 
		 * 
		 */		
		public static function getStringBytesLength(str:String,charSet:String):int  
		{  
			var bytes:ByteArray = new ByteArray();  
			bytes.writeMultiByte(str, charSet);  
			bytes.position = 0;  
			return bytes.length;  
		}  
		
		
	}
}



