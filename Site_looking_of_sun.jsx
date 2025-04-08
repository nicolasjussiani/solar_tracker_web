import { useEffect, useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Sun, Sunrise, Sunset, Compass, MoveUpRight } from "lucide-react";

export default function SolarInfo() {
  const [dadosSolares, setDadosSolares] = useState(null);

  useEffect(() => {
    fetch("http://127.0.0.1:5000/sol")
      .then((res) => res.json())
      .then((data) => setDadosSolares(data));
  }, []);

  if (!dadosSolares) {
    return <div className="text-center p-10">Carregando dados solares...</div>;
  }

  return (
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6 text-center">🌞 Informações Solares - São Paulo</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <Sunrise className="text-yellow-500" />
            <div>
              <p className="text-sm text-gray-500">Nascer do Sol</p>
              <p className="text-lg font-semibold">{dadosSolares.nascer_do_sol}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <Sun className="text-orange-400" />
            <div>
              <p className="text-sm text-gray-500">Meio-dia Solar</p>
              <p className="text-lg font-semibold">{dadosSolares.meio_dia}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <Sunset className="text-red-400" />
            <div>
              <p className="text-sm text-gray-500">Pôr do Sol</p>
              <p className="text-lg font-semibold">{dadosSolares.por_do_sol}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <Compass className="text-blue-500" />
            <div>
              <p className="text-sm text-gray-500">Azimute</p>
              <p className="text-lg font-semibold">{dadosSolares.azimute}&deg;</p>
            </div>
          </CardContent>
        </Card>

        <Card className="md:col-span-2">
          <CardContent className="p-4 flex items-center gap-4">
            <MoveUpRight className="text-green-500" />
            <div>
              <p className="text-sm text-gray-500">Elevação Solar</p>
              <p className="text-lg font-semibold">{dadosSolares.elevacao}&deg;</p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
