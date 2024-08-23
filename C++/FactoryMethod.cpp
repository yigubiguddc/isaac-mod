// FactoryMethod.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//
//工厂方法

#include <iostream>

//把new封闭起来，实现创造者和产品松耦合
//不局限与一种交通方式，可以是任何能被扩展的方式
class Transport{
public:
    virtual ~Transport() {};
    virtual void deliver() const = 0;   //成员函数不会修改成员变量的状态
};


class Truck :public Transport {
public:
    void deliver() const override {
        std::cout << "Truck transport\n";
    }
};

class Ship :public Transport {
public:
    void deliver() const override {
        std::cout << "Ship transport\n";
    }
};

class Logistics {
public:
    virtual ~Logistics(){}
    //虚拟构造器
    //const = 0表示纯虚函数,要求任何继承自 Logistics 的子类必须实现这个函数。
    virtual Transport *factoryMethod() const = 0;   //创建对象的抽象工厂，交给子类去完成实例化操作，延迟new方法
    void doSTH() const {    //处理逻辑，对扩展开放，对修改关闭,这里doSTH的逻辑基本是固定的，不需要更改
        Transport* transport = factoryMethod();
        transport->deliver();
        delete transport;
    }
};

//依赖倒置
class TruckLogistics : public Logistics {
public:
    virtual ~TruckLogistics(){}
    //子类实现纯虚函数
    virtual Transport* factoryMethod() const override{
        return new Truck();
    }
};

class ShipLogistics :public Logistics {
public:
    virtual ~ShipLogistics(){}
    virtual Transport* factoryMethod() const override {
        return new Ship();
    }
};

int main()
{
    Logistics* truckLogistics = new TruckLogistics();
    truckLogistics->factoryMethod();
    truckLogistics->doSTH();//延迟new对象
    delete truckLogistics;

    Logistics* shipLogistics = new ShipLogistics();
    shipLogistics->factoryMethod();
    shipLogistics->doSTH();
    delete shipLogistics;
    return 0;
}
