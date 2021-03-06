import { NativeModules } from 'react-native';

type AlibcType = {
  multiply(a: number, b: number): Promise<object>;
  init(appkey: string, pid: string): Promise<object>;
  login(): Promise<object>;
  isLogin(): Promise<boolean>;
  logout(): Promise<object>;
  getUser(): Promise<object>;
  open(param: object, openType: string, clientType: string): Promise<object>;
};

const { Alibc } = NativeModules;

export default Alibc as AlibcType;
